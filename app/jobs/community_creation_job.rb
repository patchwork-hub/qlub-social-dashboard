class CommunityCreationJob < ApplicationJob
  queue_as :default

  def perform(community_id, user_id)
    community = Community.find(community_id)
    user = User.find(user_id)

    CommunityPostService.new.set_default_hashtag(community, user)
  end
end