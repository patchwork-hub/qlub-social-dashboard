class CommunityHashtag < ApplicationRecord
  self.table_name = 'patchwork_communities_hashtags'

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "hashtag", "id", "id_value", "name", "patchwork_community_id", "updated_at"]
  end
end