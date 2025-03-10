class CommunityAdmin < ApplicationRecord
  self.table_name = 'patchwork_communities_admins'
  belongs_to :community, foreign_key: 'patchwork_community_id'
  belongs_to :account, foreign_key: 'account_id', optional: true

  validates :email, presence: true,
    format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" },
    uniqueness: { case_sensitive: false, message: "is already in use. Please use a different email for the organisation admin account." }

  validates :username, presence: true

  ROLES = %w[OrganisationAdmin UserAdmin HubAdmin].freeze

  validates :role, inclusion: { in: ROLES, message: "%{value} is not a valid role" }, allow_blank: true

  validates :account_id, uniqueness: { scope: :patchwork_community_id, message: "is already an admin for this community" }, allow_blank: true

  def self.ransackable_attributes(auth_object = nil)
    ["account_id", "created_at", "id", "id_value", "patchwork_community_id", "updated_at"]
  end

  validate :require_admin_role_or_boost_bot, if: :community_is_channel?

  private

  def require_admin_role_or_boost_bot
    if !organisation_admin_role? && !is_boost_bot
      errors.add(:base, "Please check 'Organisation Admin' and 'Boost Bot'.")
    end
  end

  def community_is_channel?
    community&.channel?
  end

  def organisation_admin_role?
    role == 'OrganisationAdmin'
  end

end
