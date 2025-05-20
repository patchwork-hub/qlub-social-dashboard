require 'httparty'

class FetchNewsmastAdminsService
  # This class fetches the list of admin followings from the Newsmast API.
  # It handles pagination by recursively fetching data until all pages are retrieved.
  

  def initialize(url = 'https://backend.newsmast.org', community_slug = nil, token = nil)
    @community_slug = community_slug
    @base_url = "#{url}/api/v1/communities/get_admin_following_list?id=#{@community_slug}"
    @results = []
    @token = token
  end

  def fetch_following_list(max_id = nil)
    url = max_id ? "#{@base_url}&max_id=#{max_id}" : @base_url
    response = HTTParty.get(url,
    headers: { 'Authorization' => "Bearer #{@token}" }
    )

    if response.success?
      data = response.parsed_response['data']
      meta = response.parsed_response['meta']

      @results.concat(data) unless data.empty?

      if meta['has_more_objects'] && !data.empty?
        last_id = data.last['id']
        fetch_following_list(last_id)
      end
    else
      puts "Error: Failed to fetch data from API"
    end
  end

  def run
    fetch_following_list
    @results
  end
end
