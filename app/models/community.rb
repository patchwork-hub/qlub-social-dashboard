class Community < ApplicationRecord
  self.table_name = 'patchwork_communities'

  IMAGE_MIME_TYPES = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'].freeze
  LIMIT = 2.megabytes

  NAME_LENGTH_LIMIT = 30
  SLUG_LENGTH_LIMIT = 22
  DESCRIPTION_LENGTH_LIMIT = 500

  has_attached_file :logo_image
  has_attached_file :avatar_image
  has_attached_file :banner_image

  validates :name, presence: true,
    length: { maximum: NAME_LENGTH_LIMIT, too_long: "cannot be longer than %{count} characters" }

  validates :slug, presence: true,
    format: { with: /\A[a-z0-9-]+\z/i, message: "only allows letters, numbers, and dashes" },
    length: { maximum: SLUG_LENGTH_LIMIT, too_long: "cannot be longer than %{count} characters" }

  validate :slug_uniqueness_within_accounts, on: :create

  normalizes :slug, with: ->(slug) { slug.squish.parameterize }

  validates :description, length: { maximum: DESCRIPTION_LENGTH_LIMIT, too_long: "cannot be longer than %{count} characters" }

  validates_attachment :logo_image,
                       content_type: { content_type: IMAGE_MIME_TYPES },
                       size: { less_than: LIMIT }

  validates_attachment :avatar_image,
                       content_type: { content_type: IMAGE_MIME_TYPES },
                       size: { less_than: LIMIT }

  validates_attachment :banner_image,
                       content_type: { content_type: IMAGE_MIME_TYPES },
                       size: { less_than: LIMIT }

  has_many :community_admins,
            foreign_key: 'patchwork_community_id',
            dependent: :destroy

  has_many :patchwork_community_additional_informations,
            class_name: 'CommunityAdditionalInformation',
            foreign_key: 'patchwork_community_id',
            dependent: :destroy

  accepts_nested_attributes_for :patchwork_community_additional_informations, allow_destroy: true

  has_many :community_post_types,
            foreign_key: 'patchwork_community_id',
            dependent: :destroy

  belongs_to :patchwork_collection,
            class_name: 'Collection',
            foreign_key: 'patchwork_collection_id'

  has_many :community_post_types,
            foreign_key: 'patchwork_community_id',
            dependent: :destroy


  belongs_to :patchwork_community_type,
              class_name: 'CommunityType',
              foreign_key: 'patchwork_community_type_id'

  has_one :content_type,
            class_name: 'ContentType',
            foreign_key: 'patchwork_community_id',
            dependent: :destroy

  has_many :patchwork_community_links,
            class_name: 'CommunityLink',
            foreign_key: 'patchwork_community_id',
            dependent: :destroy

  accepts_nested_attributes_for :patchwork_community_links, allow_destroy: true

  has_many :patchwork_community_rules,
            class_name: 'CommunityRule',
            foreign_key: 'patchwork_community_id',
            dependent: :destroy

  validates :name, presence: true, uniqueness: true

  enum visibility: { public_access: 0, guest_access: 1, private_local: 2 }

  def slug_uniqueness_within_accounts
    return unless slug.present?

    if Account.where(username: slug.underscore).exists?
      errors.add(:slug, "is already taken by an existing account username")
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    ["name"]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
