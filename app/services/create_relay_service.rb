require 'httparty'

class CreateRelayService
  def initialize(api_base_url, token, hashtag_name)
    @api_base_url = api_base_url
    @token = token
    @inbox_url= "https://relay.fedi.buzz/tag/#{hashtag_name}"
  end

  def call
    response = HTTParty.post("#{@api_base_url}/api/v1/patchwork/relays?inbox_url=#{@inbox_url}",
      headers: { 'Authorization' => "Bearer #{@token}" }
    )
    
    response.success?
  end
end
