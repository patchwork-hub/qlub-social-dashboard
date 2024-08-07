class Community < ApplicationRecord
  self.table_name = 'patchwork_communities'
  has_one_attached :image
  has_many :community_admins, foreign_key: 'patchwork_community_id'

  def self.ransackable_attributes(auth_object = nil)
    [ "name" ]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end