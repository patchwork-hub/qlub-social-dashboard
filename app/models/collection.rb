# == Schema Information
#
# Table name: patchwork_collections
#
#  id                        :bigint           not null, primary key
#  avatar_image_content_type :string
#  avatar_image_file_name    :string
#  avatar_image_file_size    :bigint
#  avatar_image_updated_at   :datetime
#  banner_image_content_type :string
#  banner_image_file_name    :string
#  banner_image_file_size    :bigint
#  banner_image_updated_at   :datetime
#  name                      :string           not null
#  slug                      :string           not null
#  sorting_index             :integer          not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_patchwork_collections_on_slug  (slug) UNIQUE
#
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


  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
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

  scope :filter_by_channel_type, ->(type) {
    includes(:patchwork_communities)
      .where(patchwork_communities: { channel_type: Community.channel_types[type] })
      .merge(Community.exclude_incomplete_channels)
      .distinct
    }

  # scope :filter_channels, -> { joins(:patchwork_communities).where(patchwork_communities: { channel_type: Community.channel_types[:channel] }).where.not(patchwork_communities: { visibility: nil }) }
  # scope :filter_channel_feeds, -> { joins(:patchwork_communities).where(patchwork_communities: { channel_type: Community.channel_types[:channel_feed] }).where.not(patchwork_communities: { visibility: nil }) }
  # scope :filter_newsmast, -> { joins(:patchwork_communities).where(patchwork_communities: { channel_type: Community.channel_types[:newsmast] }).where.not(patchwork_communities: { visibility: nil }) }

end
