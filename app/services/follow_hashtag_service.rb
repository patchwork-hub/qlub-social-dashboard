require 'httparty'

class FollowHashtagService
  def initialize(api_base_url, token, hashtag_name)
    @api_base_url = api_base_url
    @token = token
    @hashtag_name = hashtag_name
  end

  def call
    response = HTTParty.post("#{@api_base_url}/api/v1/tags/#{@hashtag_name}/follow",
      headers: { 'Authorization' => "Bearer #{@token}" }
    )

    response.success?
  end
end
