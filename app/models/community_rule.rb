# == Schema Information
#
# Table name: patchwork_community_rules
#
#  id                     :bigint           not null, primary key
#  rule                   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  patchwork_community_id :bigint           not null
#
# Indexes
#
#  index_patchwork_community_rules_on_patchwork_community_id  (patchwork_community_id)
#
# Foreign Keys
#
#  fk_rails_...  (patchwork_community_id => patchwork_communities.id)
#
class CommunityRule < ApplicationRecord
  self.table_name = 'patchwork_community_rules'
  belongs_to :community, class_name: 'Community', foreign_key: 'patchwork_community_id'
  validates :rule, presence: true, length: { maximum: 255 }
end
