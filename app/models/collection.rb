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
  validates :slug, presence: true, uniqueness: true
  validates :sorting_index, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, uniqueness: true

  validates_attachment :avatar_image,
  content_type: { content_type: IMAGE_MIME_TYPES },
  size: { less_than: LIMIT }

  validates_attachment :banner_image,
  content_type: { content_type: IMAGE_MIME_TYPES },
  size: { less_than: LIMIT }

  validate :validate_avatar_aspect_ratio
  validate :validate_banner_aspect_ratio

  scope :recommended_group_channels, -> {
    joins(:patchwork_communities)
      .where(patchwork_communities: { is_recommended: true })
      .where.not(patchwork_communities: { visibility: nil } )
      .where.not(patchwork_communities: { patchwork_community_type: nil} )
      .group('patchwork_collections.id')
      .order('patchwork_collections.sorting_index ASC')
  }

  private

  def validate_avatar_aspect_ratio
    validate_image_aspect_ratio(avatar_image, 1, 1, 'Avatar image')
  end

  def validate_banner_aspect_ratio
    validate_image_aspect_ratio(banner_image, 3.6, 1, 'Banner image')
  end

  def validate_image_aspect_ratio(image, width_ratio, height_ratio, image_name)
    return unless image.present? && image.queued_for_write[:original].present?

    dimensions = Paperclip::Geometry.from_file(image.queued_for_write[:original])
    actual_ratio = dimensions.width.to_f / dimensions.height
    expected_ratio = width_ratio.to_f / height_ratio

    unless (actual_ratio - expected_ratio).abs < 0.01
      errors.add(:base, "#{image_name} must have an aspect ratio of #{width_ratio}:#{height_ratio}")
    end
  end

end
