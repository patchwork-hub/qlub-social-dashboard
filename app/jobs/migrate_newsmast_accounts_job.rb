require 'csv'

class MigrateNewsmastAccountsJob < ApplicationJob
  queue_as :default

  def perform(csv_path = Rails.root.join('user_community_export.csv'))
    @missing_accounts = []
    
    owner_role = UserRole.find_by(name: 'Owner')
    owner_user = User.find_by(role: owner_role)
    return Rails.logger.error('Owner user not found. Aborting migration.') unless owner_user

    @owner_token = fetch_oauth_token(owner_user.id)
    return Rails.logger.error('Owner access token not found. Aborting migration.') unless @owner_token

    Rails.logger.info "Starting migration of accounts from #{csv_path}"

    CSV.foreach(csv_path, headers: true) do |row|
        process_batch(row)
    end
    
    # Output missing accounts at the end
    output_missing_accounts
  end

  private

  def process_batch(row)
    # Preload communities
    handle = row['handle']
    communities_json = row['communities']

    communities_data = JSON.parse(communities_json)

    primary_slug = communities_data['primary']
    other_slugs = communities_data['others'] || []

    # Combine all community slugs
    all_slugs = [primary_slug] + other_slugs

    # Prepare account queries
  
    account_id = search_target_account_id(handle, @owner_token)
    account = Account.find_by(id: account_id)
    existing_communities = Community.where(slug: all_slugs, channel_type: 'newsmast')

    if account
      JoinedCommunity.where(account_id: account.id).destroy_all

      existing_communities.each do |community|

        if primary_slug && (primary_slug == community.slug)
          is_primary = true
        else
          is_primary = false
        end
        JoinedCommunity.create!(
          account_id: account.id,
          patchwork_community_id: community.id,
          is_primary: is_primary
        )
        Rails.logger.info "Created joined_community for account #{handle}."

      end
    else
      @missing_accounts << handle
    end
  end

  def output_missing_accounts
    Rails.logger.info "="*80
    Rails.logger.info "MIGRATION COMPLETED"
    Rails.logger.info "="*80
    
    if @missing_accounts.empty?
      Rails.logger.info "✅ All accounts were found successfully!"
    else
      Rails.logger.info "❌ Missing accounts summary:"
      Rails.logger.info "Total missing accounts: #{@missing_accounts.length}"
      Rails.logger.info "-" * 80
      
      @missing_accounts.each_with_index do |account, index|
        Rails.logger.info "#{index + 1}. #{account}"
      end      
    end
    
    Rails.logger.info "="*80
  end

  def search_target_account_id(query, owner_token)
    retries = 5
    result = nil
    while retries >= 0
      result = ContributorSearchService.new(
        query,
        url: ENV['MASTODON_INSTANCE_URL'],
        token: owner_token
      ).call
      if result.any?
        return result.last['id']
      end
      retries -= 1
    end
    nil
  end

  def fetch_oauth_token(user_id)
    token_service = GenerateAdminAccessTokenService.new(user_id)
    token_service.call
  end
end