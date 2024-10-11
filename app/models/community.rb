class Community < ApplicationRecord
  self.table_name = 'patchwork_communities'
  has_one_attached :banner_image
  has_one_attached :avatar_image

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
