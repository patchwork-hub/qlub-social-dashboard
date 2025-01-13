class CommunityHashtag < ApplicationRecord
  self.table_name = 'patchwork_communities_hashtags'

  belongs_to :community, foreign_key: 'patchwork_community_id', class_name: 'Community'

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "hashtag", "id", "id_value", "name", "patchwork_community_id", "updated_at"]
  end
end
