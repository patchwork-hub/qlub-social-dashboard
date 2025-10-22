class UserBlockedByBridgeBotService
  def initialize(user, token, target_account_id)
    @user = user
    @token = token
    @target_account_id = target_account_id
  end

  def call
    return false if @user.nil? || @token.nil?

    api_base_url = ENV['MASTODON_INSTANCE_URL']
    headers = { 'Authorization' => "Bearer #{@token}" }

    # Get the current user's block list
    response = HTTParty.get(
      "#{api_base_url}/api/v1/blocks",
      headers: headers
    )

    return false unless response&.success?

    blocked_accounts = response.parsed_response
    blocked_account_ids = blocked_accounts.map { |acc| acc['id'] }
    
    blocked_account_ids.include?(@target_account_id.to_s)
  end
end
