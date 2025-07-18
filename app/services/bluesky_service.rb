class BlueskyService

  def initialize(community)
    admin_account = community&.community_admins.where(is_boost_bot: true).last
    account = Account.find_by(id: admin_account&.account_id)

    @urls = []
    @urls << "https://public.api.bsky.app/xrpc/app.bsky.actor.getProfile?actor=#{community&.slug}.channel.org" if community&.slug 
    @urls << "https://public.api.bsky.app/xrpc/app.bsky.actor.getProfile?actor=#{account&.username}.channel.org" if account&.username 
  end

  def fetch_bluesky_account
    @urls.each do |url|
      result = fetch_with_retries(url)
      return result unless result.empty?
    end

    {}
  end

  private

  def fetch_with_retries(url, retries = 2)
    begin
      response = HTTParty.get(url)

      if response.code == 200
        return JSON.parse(response.body)
      else
        return {}
      end
    rescue Socket::ResolutionError, SocketError => e
      if (retries -= 1) > 0
        sleep 1
        retry
      else
        return {}
      end
    rescue StandardError => e
      {}
    end
  end

end
