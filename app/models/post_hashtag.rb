class PostHashtag < ApplicationRecord
  self.table_name = 'post_hashtags_communities'
  belongs_to :community, foreign_key: 'patchwork_community_id'
end