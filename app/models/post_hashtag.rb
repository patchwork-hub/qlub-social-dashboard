# == Schema Information
#
# Table name: post_hashtags_communities
#
#  id                     :bigint           not null, primary key
#  hashtag                :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  patchwork_community_id :bigint           not null
#
# Indexes
#
#  index_post_hashtags_communities_on_patchwork_community_id  (patchwork_community_id)
#
# Foreign Keys
#
#  fk_rails_...  (patchwork_community_id => patchwork_communities.id) ON DELETE => cascade
#
class PostHashtag < ApplicationRecord
  self.table_name = 'post_hashtags_communities'
  belongs_to :community, foreign_key: 'patchwork_community_id'

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "hashtag", "id", "id_value", "patchwork_community_id", "updated_at"]
  end
end
