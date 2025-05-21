class SetHashtagsJob < ApplicationJob
  queue_as :default
  retry_on StandardError, attempts: 0

  def perform(community, user, channel, url, newsmast_account_token)
    return nil if community.nil? || user.nil?

    slug = channel[:attributes][:slug]
    # Fetch hashtags from newsmast.social
    hashtags = FetchNewsmastHashtagsService.new(
      url,
      newsmast_account_token,
      slug,
      true
      ).call

    unless CommunityHashtag.exists?(patchwork_community_id: community.id)
      hashtags.each do |hashtag|
        CommunityHashtagPostService.new.call(hashtag: hashtag['hashtag'], community_id: community.id)

        ManageHashtagService.new(
          hashtag['hashtag'],
          :follow,
          ENV['MASTODON_INSTANCE_URL'],
          fetch_oauth_token(user.id),
          community.id,
        ).call
      end
    end
  end

  private

  def fetch_oauth_token(user_id)
    token_service = GenerateAdminAccessTokenService.new(user_id)
    token_service.call
  end
end
