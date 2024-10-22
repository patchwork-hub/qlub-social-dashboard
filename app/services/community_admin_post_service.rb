# frozen_string_literal: true

class CommunityAdminPostService < BaseService
  def call(account, options = {})
    @optons = options
    create_account
    create_user
    process_community_admin!
  end

  private

  def create_account
    community = Community.find_by_id(@optons[:community_id].to_i)
    avatar_file = community.avatar_image.present? ? community.avatar_image : ''
    banner_file = community.banner_image.present? ? community.banner_image : ''
    @admin_acc = Account.where(username: @optons[:username]).first_or_initialize(username: @optons[:username], display_name: @optons[:display_name])
    @admin_acc.avatar = avatar_file
    @admin_acc.header = banner_file
    @admin_acc.save
  end

  def create_user
    @user = User.where(email: @optons[:email]).first_or_initialize(email: @optons[:email], password: @optons[:password], password_confirmation: @optons[:password], role_id: '4', confirmed_at: Time.now.utc, account: @admin_acc, approved: true)
    @user.save
  end

  def community_admin_attribute
    {
      account_id: @admin_acc.id,
      patchwork_community_id: @optons[:community_id].to_i
    }.compact
  end

  def process_community_admin!
    @community_admin = CommunityAdmin.where(account_id: @admin_acc.id, patchwork_community_id: @optons[:community_id].to_i).first_or_initialize(community_admin_attribute)
    @community_admin.save!
  end
end
