class CommunityType < ApplicationRecord
  self.table_name = 'patchwork_community_types'

    has_many :patchwork_communities,
             class_name: 'Community',
             foreign_key: 'patchwork_community_type_id',
             dependent: :destroy
end