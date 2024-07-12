class Community < ApplicationRecord
  self.table_name = 'patchwork_communities'
  has_one_attached :image
end