require 'httparty'

class DeleteRelayService
  def initialize(api_base_url, token, relay_id)
    @api_base_url = api_base_url
    @token = token
    @relay_id = relay_id
  end

  def call
    response = HTTParty.delete("#{@api_base_url}/api/v1/patchwork/relays/#{@relay_id}",
      headers: { 'Authorization' => "Bearer #{@token}" }
    )
    
    response.success?
  end
end