class User < ApplicationRecord
  belongs_to :role, class_name: 'UserRole', inverse_of: :users
  belongs_to :account, inverse_of: :user
  has_many :community_admins, inverse_of: :user
  has_many :community_users, inverse_of: :user

  validates :agreement, acceptance: { allow_nil: false, accept: [true, 'true', '1'] }, on: :create

  devise :database_authenticatable, stretches: 13

  validates :email, uniqueness: true, presence: true

  def owner?
    role.name == 'Owner'
  end

  def primary_community
    if community_users.any?
      cu = community_users.find_by(is_primary: true)
      return cu.community.name if cu.present?
    end
  end
end
