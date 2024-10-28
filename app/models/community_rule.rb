class CommunityRule < ApplicationRecord
  self.table_name = 'patchwork_community_rules'
  belongs_to :rule, foreign_key: 'patchwork_rules_id'
  belongs_to :community, class_name: 'Community', foreign_key: 'patchwork_community_id'
end
