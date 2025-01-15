# frozen_string_literal: true
require 'httparty'

class SearchAccountService
  def initialize(query, options = {})
    @query = query
    @api_base_url = options[:url]
    @token = options[:token]
    @account_id = options[:account_id]
  end

  def call
    response = search_mastodon
    puts "[SearchAccountService] response: #{response}"

    accounts = response.parsed_response['accounts']
    puts "[SearchAccountService] accounts: #{accounts}"
    puts "[SearchAccountService] find_saved_accounts_with_retry: #{find_saved_accounts_with_retry(accounts)}"
    find_saved_accounts_with_retry(accounts)
  end

  private

  def search_mastodon
    HTTParty.get("#{@api_base_url}/api/v2/search",
      query: {
        q: @query,
        resolve: true,
        limit: 11
      },
      headers: {
        'Authorization' => "Bearer #{@token}"
      }
    )
  end

  def find_saved_accounts_with_retry(accounts)
    return [] unless accounts.present?

    saved_accounts = []
    saved_accounts = Account.where(username: accounts.map { |account| account['username'] })

    saved_accounts.map do |account|
      profile_url = generate_profile_url(account)

      {
        'id' => account.id.to_s,
        'username' => account.username,
        'display_name' => account.display_name,
        'domain' => account.domain,
        'note' => account.note,
        'avatar_url' => account.avatar_url,
        'profile_url' => profile_url,
        'following' => following_status(account),
        'is_muted' => is_muted(account)
      }
    end
  end

  def generate_profile_url(account)
    return "https://#{account.domain}/@#{account.username}" if account&.domain.present?

    env = ENV.fetch('RAILS_ENV', nil)
    case env
    when 'staging'
      "https://staging.patchwork.online/@#{account.username}"
    when 'production'
      "https://channel.org/@#{account.username}"
    else
      "https://localhost:3000/@#{account.username}"
    end
  end

  def following_status(account)
    follow_ids = Follow.where(account_id: @account_id).pluck(:target_account_id)
    follow_request_ids = FollowRequest.where(account_id: @account_id).pluck(:target_account_id)

    if follow_ids.include?(account.id)
      'following'
    elsif follow_request_ids.include?(account.id)
      'requested'
    else
      'not_followed'
    end
  end

  def is_muted(account)
    Mute.where(account_id: @account_id, target_account_id: account.id).exists?
  end
end