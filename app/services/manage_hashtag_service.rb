class ManageHashtagService < BaseService
  def initialize(hashtag_name, action, api_base_url, token, community_id = nil)
    @hashtag_name = hashtag_name.gsub('#', '')
    @action = action
    @api_base_url = api_base_url
    @token = token
    @community_id = community_id
  end

  def call
    hashtag = SearchHashtagService.new(@api_base_url, @token, @hashtag_name).call
    return puts "Hashtag not found" unless hashtag

    service_class = @action == :follow ? FollowHashtagService : UnfollowHashtagService
    result = service_class.new(@api_base_url, @token, hashtag[:name]).call
    puts result ? "Successfully #{@action}ed ##{hashtag[:name]}" : "Failed to #{@action} ##{hashtag[:name]}"

    owner_role = UserRole.find_by(name: 'Owner')
    owner_user = User.find_by(role: owner_role)
    token = fetch_oauth_token(owner_user.id)

    if @action == :follow
      create_relay(@hashtag_name, token)
    elsif @action == :unfollow
      unless CommunityHashtag.where(name: @hashtag_name).where.not(patchwork_community_id: @community_id).exists?
        delete_relay(@hashtag_name, token)
      end
    end
  end

  private

  def create_relay(hashtag_name, token)
    inbox_url = "https://relay.fedi.buzz/tag/#{hashtag_name}"
    unless Relay.exists?(inbox_url: inbox_url)
      CreateRelayService.new(@api_base_url, token, hashtag_name).call
    end
  end

  def delete_relay(hashtag_name, token)
    inbox_url = "https://relay.fedi.buzz/tag/#{hashtag_name}"
    relay = Relay.find_by(inbox_url: inbox_url)
    if relay
      DeleteRelayService.new(@api_base_url, token, relay.id).call
    end
  end

  def fetch_oauth_token(user_id)
    token_service = GenerateAdminAccessTokenService.new(user_id)
    token_service.call
  end
end
