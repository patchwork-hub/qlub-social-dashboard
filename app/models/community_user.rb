class CommunityUser < ApplicationRecord
  self.table_name = 'mammoth_communities_users'

  belongs_to :user, inverse_of: :community_users
  belongs_to :community, inverse_of: :community_users
end