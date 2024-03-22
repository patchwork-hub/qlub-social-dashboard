class BanStatus < ApplicationRecord
  self.table_name = 'mammoth_community_filter_statuses'

  belongs_to :status, inverse_of: :ban_statuses
  belongs_to :global_filter, inverse_of: :ban_statuses, foreign_key: :community_filter_keyword_id
end