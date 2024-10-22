class Community < ApplicationRecord
  self.table_name = 'patchwork_communities'

  IMAGE_MIME_TYPES = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'].freeze
  LIMIT = 2.megabytes

  NAME_LENGTH_LIMIT = 30
  DESCRIPTION_LENGTH_LIMIT = 500

  has_attached_file :avatar_image
  has_attached_file :banner_image

  validates :name, presence: true,
    length: { maximum: NAME_LENGTH_LIMIT, too_long: "cannot be longer than %{count} characters" }

  validates :slug, presence: true,
    format: { with: /\A[a-z0-9_]+\z/i, message: "only allows letters, numbers, and underscores" },
    length: { maximum: NAME_LENGTH_LIMIT, too_long: "cannot be longer than %{count} characters" }

  normalizes :slug, with: ->(slug) { slug.squish.parameterize.underscore }

  validates :description, length: { maximum: DESCRIPTION_LENGTH_LIMIT, too_long: "cannot be longer than %{count} characters" }

  validates_attachment_content_type :avatar_image, content_type: IMAGE_MIME_TYPES
  validates_attachment_content_type :banner_image, content_type: IMAGE_MIME_TYPES

  validates_attachment_size :avatar_image, less_than: LIMIT
  validates_attachment_size :banner_image, less_than: LIMIT

  has_many :community_admins,
            foreign_key: 'patchwork_community_id'

  has_many :patchwork_community_additional_informations,
            class_name: 'CommunityAdditionalInformation',
            foreign_key: 'patchwork_community_id',
            dependent: :destroy

  has_many :community_post_types,
            foreign_key: 'patchwork_community_id',
            dependent: :destroy

  belongs_to :patchwork_collection,
            class_name: 'Collection',
            foreign_key: 'patchwork_collection_id'

  has_many :community_post_types,
            foreign_key: 'patchwork_community_id',
            dependent: :destroy


  belongs_to :patchwork_collection,
            class_name: 'Collection',
            foreign_key: 'patchwork_collection_id'

  accepts_nested_attributes_for :patchwork_community_additional_informations, allow_destroy: true

  validates :name, presence: true, uniqueness: true

  enum visibility: { public_access: 0, guest_access: 1, private_local: 2 }

  def self.ransackable_attributes(auth_object = nil)
    ["name"]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
