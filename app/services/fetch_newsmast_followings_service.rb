require 'httparty'

class FetchNewsmastFollowingsService
  def initialize(api_base_url, token, id)
    @api_base_url = api_base_url
    @token = token
    @id = id
  end

  def call
    response = HTTParty.get("#{@api_base_url}/api/v1/#{@id}/following",
      headers: { 'Authorization' => "Bearer #{@token}" }
    )

    if response.success?
      response.any?
    else
      nil
    end
  end
end
