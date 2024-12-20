class Collection < ApplicationRecord
  self.table_name = 'patchwork_collections'

  IMAGE_MIME_TYPES = ['image/svg+xml', 'image/png', 'image/jpeg', 'image/jpg'].freeze
  LIMIT = 2.megabytes

  has_many :patchwork_communities,
            class_name: 'Community',
            foreign_key: 'patchwork_collection_id',
            dependent: :destroy

  has_attached_file :avatar_image
  has_attached_file :banner_image


  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true
  validates :sorting_index, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, uniqueness: true

  validates_attachment :avatar_image,
  content_type: { content_type: IMAGE_MIME_TYPES },
  size: { less_than: LIMIT }

  validates_attachment :banner_image,
  content_type: { content_type: IMAGE_MIME_TYPES },
  size: { less_than: LIMIT }

  scope :recommended_group_channels, -> {
    joins(:patchwork_communities)
      .where(patchwork_communities: { is_recommended: true })
      .where.not(patchwork_communities: { visibility: nil } )
      .where.not(patchwork_communities: { patchwork_community_type: nil} )
      .group('patchwork_collections.id')
      .order('patchwork_collections.sorting_index ASC')
  }
end
