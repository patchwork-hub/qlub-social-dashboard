require 'httparty'

class FetchNewsmastHashtagsService
  def initialize(api_base_url, token, slug, is_incoming)
    @api_base_url = api_base_url
    @token = token
    @slug = slug
    @is_incoming = is_incoming
  end

  def call
    response = HTTParty.get("#{@api_base_url}/api/v1/community_hashtags",
      query: { slug: @slug, is_incoming: @is_incoming },
      headers: { 'Authorization' => "Bearer #{@token}" }
    )

    if response.success?
      response['data']
    else
      nil
    end
  end
end
