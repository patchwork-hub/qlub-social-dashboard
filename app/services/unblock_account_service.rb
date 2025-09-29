class UnblockAccountService
  def initialize(token, target_account_id)
    @token = token
    @target_account_id = target_account_id
  end

  def call
    return false if @token.nil? || @target_account_id.nil?

    api_base_url = ENV['MASTODON_INSTANCE_URL']
    headers = { 'Authorization' => "Bearer #{@token}" }

    response = HTTParty.post(
      "#{api_base_url}/api/v1/accounts/#{@target_account_id}/unblock",
      headers: headers
    )

    response&.success?
  end
end
