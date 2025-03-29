# == Schema Information
#
# Table name: patchwork_community_post_types
#
#  id                     :bigint           not null, primary key
#  posts                  :boolean          default(FALSE), not null
#  replies                :boolean          default(FALSE), not null
#  reposts                :boolean          default(FALSE), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  patchwork_community_id :bigint           not null
#
# Indexes
#
#  index_patchwork_community_post_types_on_patchwork_community_id  (patchwork_community_id)
#
# Foreign Keys
#
#  fk_rails_...  (patchwork_community_id => patchwork_communities.id) ON DELETE => cascade
#
class CommunityPostType < ApplicationRecord
  self.table_name = 'patchwork_community_post_types'
  belongs_to :community, class_name: 'Community', foreign_key: 'patchwork_community_id'
end
