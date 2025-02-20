class BlueskyService
  def initialize(community)
    @community = community
    @url = "https://public.api.bsky.app/xrpc/app.bsky.actor.getProfile?actor=#{@community&.slug}.channel.org"
  end

  def fetch_bluesky_account
    response = HTTParty.get(@url)
    if response.code == 200
      results = JSON.parse(response.body)
      Rails.logger.info("Fetched bluesky account: #{results}")
      results
    else
      Rails.logger.error("Failed to fetch bluesky account: #{@community&.slug} => #{response.body}")
      {}
    end
  end
end
