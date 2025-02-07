class JoinedCommunity < ApplicationRecord
  self.table_name = 'patchwork_joined_communities'

  belongs_to :community, foreign_key: 'patchwork_community_id'
  belongs_to :account, foreign_key: 'account_id'

  validates :community, presence: true
  validates :account, presence: true, uniqueness: { scope: :patchwork_community_id }
end