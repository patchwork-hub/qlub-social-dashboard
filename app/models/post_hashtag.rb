class PostHashtag < ApplicationRecord
  self.table_name = 'post_hashtags_communities'
  belongs_to :community, foreign_key: 'patchwork_community_id'

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "hashtag", "id", "id_value", "patchwork_community_id", "updated_at"]
  end
end