require 'csv'

class MigrateNewsmastAccountsJob < ApplicationJob
  queue_as :default
  BATCH_SIZE = 100

  def perform(csv_path = Rails.root.join('user_community_export.csv'))
    @missing_accounts = []
    
    owner_role = UserRole.find_by(name: 'Owner')
    owner_user = User.find_by(role: owner_role)
    return Rails.logger.error('Owner user not found. Aborting migration.') unless owner_user

    @owner_token = fetch_oauth_token(owner_user.id)
    return Rails.logger.error('Owner access token not found. Aborting migration.') unless @owner_token

    Rails.logger.info "Starting migration of accounts from #{csv_path}"

    batch = []
    CSV.foreach(csv_path, headers: true) do |row|
      batch << row
      if batch.size >= BATCH_SIZE
        process_batch(batch)
        batch = []
      end
    end
    process_batch(batch) if batch.any?
    
    # Output missing accounts at the end
    output_missing_accounts
  end

  private

  def process_batch(rows)
    # Preload communities
    slugs = rows.map { |r| r['slug'].tr('_', '-') }
    names = rows.map { |r| r['name'] }
    communities = Community.where(slug: slugs, name: names, channel_type: 'newsmast').index_by { |c| [c.slug, c.name] }

    # Prepare account queries
    acct_queries = rows.map { |r| "@#{r['username']}@#{r['domain']}" }.uniq
    account_id_map = {}
    acct_queries.each do |acct|
      account_id_map[acct] = search_target_account_id(acct, @owner_token)
    end
    accounts = Account.where(id: account_id_map.values.compact).index_by(&:id)
    
    rows.each do |row|
      username, domain, name, slug, is_primary = row.values_at('username', 'domain', 'name', 'slug', 'is_primary')
      community = communities[[slug.tr('_', '-'), name]]
      unless community
        Rails.logger.error "Community not found: #{name} (#{slug.tr('_', '-')}) for user acct: #{username}@#{domain}"
        next
      end

      acct = "@#{username}@#{domain}"
      target_account_id = account_id_map[acct]
      target_account = accounts[target_account_id.to_i]
      unless target_account
        # Store missing account in array
        @missing_accounts << {
          username: username,
          domain: domain,
          acct: acct,
          community_name: name,
          community_slug: slug.tr('_', '-'),
          target_account_id: target_account_id
        }
        Rails.logger.error "Account not found for user acct: #{username}@#{domain}"
        next
      end

      is_primary_bool = ActiveModel::Type::Boolean.new.cast(is_primary)
      joined_community = JoinedCommunity.find_by(account_id: target_account.id, patchwork_community_id: community.id)
      if joined_community
        if is_primary_bool
          JoinedCommunity.where(account_id: target_account.id).where.not(id: joined_community.id).update_all(is_primary: false)
        end
        joined_community.update(is_primary: is_primary_bool)
        Rails.logger.info "Updated joined_community for account #{username}@#{domain} in community #{name} (#{slug})"
      else
        if is_primary_bool
          JoinedCommunity.where(account_id: target_account.id).update_all(is_primary: false)
        end
        JoinedCommunity.create!(
          account_id: target_account.id,
          patchwork_community_id: community.id,
          is_primary: is_primary_bool
        )
        Rails.logger.info "Created joined_community for account #{username}@#{domain} in community #{name} (#{slug})"
      end
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
        Rails.logger.info "#{index + 1}. #{account[:acct]} -> #{account[:community_name]} (#{account[:community_slug]})"
        Rails.logger.info "   Target ID: #{account[:target_account_id] || 'Not found'}"
      end
      
      Rails.logger.info "-" * 80
      Rails.logger.info "Missing accounts by domain:"
      domain_counts = @missing_accounts.group_by { |a| a[:domain] }.transform_values(&:count)
      domain_counts.each do |domain, count|
        Rails.logger.info "  #{domain}: #{count} accounts"
      end
    end
    
    Rails.logger.info "="*80
  end

  def search_target_account_id(query, owner_token)
    @account_id_cache ||= {}
    return @account_id_cache[query] if @account_id_cache.key?(query)

    retries = 5
    result = nil
    while retries >= 0
      result = ContributorSearchService.new(
        query,
        url: ENV['MASTODON_INSTANCE_URL'],
        token: owner_token
      ).call
      if result.any?
        @account_id_cache[query] = result.last['id']
        return result.last['id']
      end
      retries -= 1
    end
    @account_id_cache[query] = nil
    nil
  end

  def fetch_oauth_token(user_id)
    token_service = GenerateAdminAccessTokenService.new(user_id)
    token_service.call
  end
end