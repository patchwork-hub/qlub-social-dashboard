class Community < ApplicationRecord
  self.table_name = 'patchwork_communities'
  has_attached_file :avatar_image,
                    path: "community/:slug/avatar_image/:filename",
                    s3_protocol: :https,
                    url: ":s3_domain_url"

  has_attached_file :banner_image,
                    path: "community/:slug/banner_image/:filename",
                    s3_protocol: :https,
                    url: ":s3_domain_url"

  validates_attachment_content_type :avatar_image, content_type: /\Aimage\/.*\z/
  validates_attachment_content_type :banner_image, content_type: /\Aimage\/.*\z/

  has_many :community_admins, foreign_key: 'patchwork_community_id'

  has_many :patchwork_community_additional_informations,
           class_name: 'CommunityAdditionalInformation',
           foreign_key: 'patchwork_community_id',
           dependent: :destroy

  has_many :community_post_types, foreign_key: 'patchwork_community_id', dependent: :destroy

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
