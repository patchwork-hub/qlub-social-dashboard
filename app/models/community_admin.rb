class CommunityAdmin < ApplicationRecord
  self.table_name = 'mammoth_communities_admins'

  belongs_to :community, inverse_of: :community_admins
  belongs_to :user, inverse_of: :community_admins
end