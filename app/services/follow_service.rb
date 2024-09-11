# frozen_string_literal: true

class FollowService < BaseService
  def call(account, target_account, mastodon_id)
    @account = account
    @target_account = target_account
    @target_mastodon_id = mastodon_id

    follow_contributor!
  end

  def follow_contributor!
    api_base_url = ENV['MASTODON_INSTANCE_URL']
    token = fetch_oauth_token || ENV['MASTODON_APPLICATION_TOKEN']

    if api_base_url.nil? || token.nil?
      puts 'Error: Mastodon instance URL or application token is missing'
      return
    end

    if api_base_url.nil? || token.nil?
      puts 'Error: Mastodon instance URL or application token is missing'
      return
    end

    response = follow_account(api_base_url, token)

    unless response.success?
      puts "Error: Failed to fetch accounts from Mastodon API: #{response.message}"
      return
    end

    account_data = process_api_response(response)

    account = find_account(account_data)

    if account
      puts "Account found: #{account.inspect}"
      return account
    else
      puts 'Account not found!!!'
    end

  rescue HTTParty::Error => e
    puts "HTTP request failed: #{e.message}"
  rescue StandardError => e
    puts "An unexpected error occurred: #{e.message}"
  end

  def follow_account(api_base_url, token)
    payload = { reblogs: true }
    headers = { 'Authorization' => "Bearer #{token}" }
    HTTParty.post("#{api_base_url}/api/v1/accounts/#{@target_mastodon_id}/follow",
      body: payload,
      headers: headers
    )
  end

  def process_api_response(response)
    sleep 2
    account_data = response.parsed_response
    return nil if account_data.nil?

    account_data
  end

  def fetch_oauth_token
    return nil unless @account.user
    OauthAccessToken.find_by(resource_owner_id: @account.user.id).token
  end

  def find_account(account_data)
    Account.find_by(id: @target_account.id)
  end

  def follow_attributes
    {
      target_account_id: @target_account.id,
      account_id: @source_account.id,
      show_reblogs: true,
      uri: nil,
      notify: true,
      languages: nil
    }.compact
  end

  def direct_follow!
    @follow = Follow.find_or_create_by(follow_attributes)
  end
end
