class BlueskyService
  def initialize(community)
    @community = community
    @url = "https://public.api.bsky.app/xrpc/app.bsky.actor.getProfile?actor=#{@community&.slug}.channel.org"
  end

  def fetch_bluesky_account
    retries = 2
    begin
      response = HTTParty.get(@url)

      return JSON.parse(response.body) if response.code == 200

      Rails.logger.error("Failed to fetch bluesky account: #{@community&.slug} => #{response.body}")
      {}
    rescue Socket::ResolutionError, SocketError => e
      if (retries -= 1) > 0
        sleep 1
        retry
      end
      Rails.logger.error("Network error after retries: #{e.message}")
      {}
    rescue StandardError => e
      Rails.logger.error("Unexpected error: #{e.message}")
      {}
    end
  end

end
