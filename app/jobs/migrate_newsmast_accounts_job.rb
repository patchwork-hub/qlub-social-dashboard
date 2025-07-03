require 'csv'

class MigrateNewsmastAccountsJob < ApplicationJob
  queue_as :default
  BATCH_SIZE = 100

  def perform(csv_path = Rails.root.join('user_community_export.csv'))
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
  end

  private

  def process_batch(rows)
    # Preload communities
    slugs = rows.map { |r| r['slug'] }
    names = rows.map { |r| r['name'] }
    communities = Community.where(slug: slugs, name: names).index_by { |c| [c.slug, c.name] }

    # Prepare account queries
    acct_queries = rows.map { |r| "@#{r['username']}@#{r['domain']}" }.uniq
    account_id_map = {}
    acct_queries.each do |acct|
      account_id_map[acct] = search_target_account_id(acct, @owner_token)
    end
    accounts = Account.where(id: account_id_map.values.compact).index_by(&:id)
    rows.each do |row|
      username, domain, name, slug, is_primary = row.values_at('username', 'domain', 'name', 'slug', 'is_primary')
      community = communities[[slug, name]]
      unless community
        Rails.logger.error "Community not found: #{name} (#{slug}) for user acct: #{username}@#{domain}"
        next
      end

      acct = "@#{username}@#{domain}"
      target_account_id = account_id_map[acct]
      target_account = accounts[target_account_id.to_i]
      unless target_account
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
