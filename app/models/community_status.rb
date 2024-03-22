class CommunityStatus < ApplicationRecord
  self.table_name = 'mammoth_communities_statuses'
  
  has_attached_file :image
end