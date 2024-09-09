class CommunityRule < ApplicationRecord
  self.table_name = 'patchwork_community_rules'
  belongs_to :rule, foreign_key: 'patchwork_rules_id'
end
