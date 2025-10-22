# == Schema Information
#
# Table name: users
#
#  id                        :bigint           not null, primary key
#  approved                  :boolean          default(TRUE), not null
#  bluesky_bridge_enabled    :boolean          default(FALSE), not null
#  chosen_languages          :string           is an Array
#  confirmation_sent_at      :datetime
#  confirmation_token        :string
#  confirmed_at              :datetime
#  consumed_timestep         :integer
#  current_sign_in_at        :datetime
#  did_value                 :string
#  disabled                  :boolean          default(FALSE), not null
#  email                     :string           default(""), not null
#  encrypted_otp_secret      :string
#  encrypted_otp_secret_iv   :string
#  encrypted_otp_secret_salt :string
#  encrypted_password        :string           default(""), not null
#  last_emailed_at           :datetime
#  last_sign_in_at           :datetime
#  locale                    :string
#  otp_backup_codes          :string           is an Array
#  otp_required_for_login    :boolean          default(FALSE), not null
#  otp_secret                :string
#  reset_password_sent_at    :datetime
#  reset_password_token      :string
#  settings                  :text
#  sign_in_count             :integer          default(0), not null
#  sign_in_token             :string
#  sign_in_token_sent_at     :datetime
#  sign_up_ip                :inet
#  skip_sign_in_token        :boolean
#  time_zone                 :string
#  unconfirmed_email         :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  account_id                :bigint           not null
#  created_by_application_id :bigint
#  invite_id                 :bigint
#  role_id                   :bigint
#  webauthn_id               :string
#
# Indexes
#
#  index_users_on_account_id                 (account_id)
#  index_users_on_confirmation_token         (confirmation_token) UNIQUE
#  index_users_on_created_by_application_id  (created_by_application_id) WHERE (created_by_application_id IS NOT NULL)
#  index_users_on_email                      (email) UNIQUE
#  index_users_on_reset_password_token       (reset_password_token) UNIQUE WHERE (reset_password_token IS NOT NULL)
#  index_users_on_role_id                    (role_id) WHERE (role_id IS NOT NULL)
#  index_users_on_unconfirmed_email          (unconfirmed_email) WHERE (unconfirmed_email IS NOT NULL)
#
# Foreign Keys
#
#  fk_50500f500d  (account_id => accounts.id) ON DELETE => cascade
#  fk_rails_...   (created_by_application_id => oauth_applications.id) ON DELETE => nullify
#  fk_rails_...   (invite_id => invites.id) ON DELETE => nullify
#  fk_rails_...   (role_id => user_roles.id) ON DELETE => nullify
#
class User < ApplicationRecord
  devise :database_authenticatable, :validatable

  belongs_to :role, class_name: 'UserRole', inverse_of: :users

  belongs_to :account, inverse_of: :user

  validates :agreement, acceptance: { allow_nil: false, accept: [true, 'true', '1'] }, on: :create

  devise :database_authenticatable, stretches: 13

  validates :email, uniqueness: true, presence: true

  def master_admin?
    role.name == 'MasterAdmin'
  end

  def organisation_admin?
    role.name == 'OrganisationAdmin'
  end

  def user_admin?
    role.name == 'UserAdmin'
  end

  def hub_admin?
    role.name == 'HubAdmin'
  end

  def newsmast_admin?
    role.name == "NewsmastAdmin"
  end

  def primary_community
    if community_users.any?
      cu = community_users.find_by(is_primary: true)
      return cu.community.name if cu.present?
    end
  end

  def self.update_all_discoverability(value = false)
    find_each(batch_size: 1000) do |user|
      settings_hash = user.settings.present? ? JSON.parse(user.settings) : {}
      settings_hash["noindex"] = value
      user.update_column(:settings, settings_hash.to_json)
    end
  end

  def self.update_all_bluesky_bridge_enabled(value = false)
    sanitized_value = !!value

    if sanitized_value
      where(did_value: nil).update_all(bluesky_bridge_enabled: true)
    else
      update_all(bluesky_bridge_enabled: sanitized_value)
    end
  end
end
