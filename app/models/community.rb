class Community < ApplicationRecord
  self.table_name = 'mammoth_communities'

  has_many :community_admins, inverse_of: :community
  has_many :community_users, inverse_of: :community
  has_many :community_hashtags, inverse_of: :community

  has_attached_file :image
end