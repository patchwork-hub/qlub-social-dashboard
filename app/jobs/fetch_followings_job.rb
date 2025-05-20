class FetchFollowingsJob < ApplicationJob
  queue_as :default
  retry_on StandardError, attempts: 0

  def perform(channel, account, owner_token, backend_url, newsmast_account_token)
    return if channel.nil? || account.nil? || owner_token.nil?

    slug = channel[:attributes][:slug] 
    newsmast_admins = FetchNewsmastAdminsService.new(
    backend_url,
    slug,
    newsmast_account_token,
    ).run

    unless newsmast_admins.empty?
      newsmast_admins.each do |admin|
        next if admin['username'].match?(/bsky\.brid\.gy|-test-/)

        domain = admin['domain'] || 'newsmast.social'
        target_account_id = search_target_account_id("@#{admin['username']}@#{domain}", owner_token)
        target_account = Account.find_by(id: target_account_id)
        next if target_account.nil?

        relationship = handle_relationship(account, target_account.id)
        next if relationship&.last&.[]('following') == true

        if account && target_account
          FollowService.new.call(account, target_account)
          puts "  ✓ Followed account: #{account.username} -> #{target_account.username}"
        else
          puts "  ✗ Followed account (account or target_account missing username)"
        end

      end
    else
      puts "No admins found for channel: #{channel[:attributes][:name]}"
    end
  end

  private

  def search_target_account_id(query, owner_token)
    query = query
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

  def handle_relationship(account, target_account_id)
    AccountRelationshipsService.new.call(account, target_account_id)
  end
end