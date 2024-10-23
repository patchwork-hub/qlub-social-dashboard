class Collection < ApplicationRecord
  self.table_name = 'patchwork_collections'

  has_many :patchwork_communities,
            class_name: 'Community',
            foreign_key: 'patchwork_collection_id',
            dependent: :destroy


  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :sorting_index, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, uniqueness: true

  #joins(patchwork_communities: :patchwork_community_type)
  scope :recommended_group_channels, -> {
    joins(:patchwork_communities)
      .where(patchwork_communities: { is_recommended: true })
      .where.not(patchwork_communities: { visibility: nil } )
      .group('patchwork_collections.id')
      .order('patchwork_collections.sorting_index ASC')
  }

end
