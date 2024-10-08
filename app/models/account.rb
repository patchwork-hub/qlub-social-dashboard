require 'spreadsheet'

class Account < ApplicationRecord
  has_one :user, inverse_of: :account
  has_many :communities
  has_many :community_admins

  before_create :generate_keys

  validates :username, uniqueness: true, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["dob", "domain", "uri", "url", "username"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["community_admins"]
  end

  def followed?(target_account_id)
    Follow.exists?(account_id: id, target_account_id: target_account_id)
  end

  def self.filter_unfollowed_users(account_id)
    Account.left_joins(:follows)
           .where.not(follows: { account_id: account_id })
           .distinct
  end

  def avatar_url
    if avatar_remote_url.present?
      avatar_remote_url
    elsif avatar_file_name.present?
      "https://#{ENV['S3_BUCKET']}/accounts/avatars/#{id}/original/#{avatar_file_name}"
    else
      ActionController::Base.helpers.asset_path('patchwork-logo.svg')
    end
  end

  def generate_keys
    return unless local? && private_key.blank? && public_key.blank?

    keypair = OpenSSL::PKey::RSA.new(2048)
    self.private_key = keypair.to_pem
    self.public_key  = keypair.public_key.to_pem
  end

  def local?
    domain.nil?
  end

end
