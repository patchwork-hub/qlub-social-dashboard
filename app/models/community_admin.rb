class CommunityAdmin < ApplicationRecord
  self.table_name = 'patchwork_communities_admins'
  belongs_to :account
  belongs_to :community

  def self.ransackable_attributes(auth_object = nil)                                                                                                      
    ["account_id", "created_at", "id", "id_value", "patchwork_community_id", "updated_at"]
  end
  
  def self.ransackable_associations(auth_object = nil)
    ["account"]
  end
end