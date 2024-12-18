class CommunityRule < ApplicationRecord
  self.table_name = 'patchwork_community_rules'
  belongs_to :community, class_name: 'Community', foreign_key: 'patchwork_community_id'
  validates :rule, presence: true, length: { maximum: 255 }
end
