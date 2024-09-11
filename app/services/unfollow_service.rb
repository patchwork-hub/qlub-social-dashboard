# frozen_string_literal: true

class UnfollowService < BaseService
  def call(account, target_account, mastodon_id)
    @source_account = account
    @target_account = target_account
    @target_mastodon_id = mastodon_id
    follow_contributor!
  end

  def follow_contributor!
    api_base_url = ENV['MASTODON_INSTANCE_URL']
    token = ENV['MASTODON_APPLICATION_TOKEN']

    if api_base_url.nil? || token.nil?
      puts 'Error: Mastodon instance URL or application token is missing'
      return
    end
    puts "api_base_url: #{api_base_url}"
    response = unfollow_account(api_base_url, token)

    unless response.success?
      puts "Error: Failed to fetch accounts from Mastodon API: #{response.message}"
      return
    end

    account_data = process_api_response(response)

    account = find_account(account_data)

    if account
      puts "Account: #{account.inspect}"
    else
      puts 'Account not found!!!'
    end

  rescue HTTParty::Error => e
    puts "HTTP request failed: #{e.message}"
  rescue StandardError => e
    puts "An unexpected error occurred: #{e.message}"
  end

  def unfollow_account(api_base_url, token)
    payload = { reblogs: true }
    headers = { 'Authorization' => "Bearer #{token}" }

    HTTParty.post("#{api_base_url}/api/v1/accounts/#{@target_mastodon_id}/unfollow",
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

  def find_account(account_data)
    account_id = account_data['id']
    return nil unless account_id

    Account.find_by(id: account_id)
  end

  def follow_attributes
    {
      target_account_id: @@target_account.id,
      account_id: @source_account.id,
      show_reblogs: true,
      uri: nil,
      notify: false,
      languages: nil
    }.compact
  end

  def direct_unfollow!
    @follow = Follow.find_by(follow_attributes)
    @follow&.destroy
  end
end
