class CommunityFilterKeyword < ApplicationRecord
  self.table_name = 'patchwork_communities_filter_keywords'

  validates :keyword, presence: true
end