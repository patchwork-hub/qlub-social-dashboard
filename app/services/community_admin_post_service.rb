# frozen_string_literal: true

class CommunityAdminPostService < BaseService
  def call(account, options = {})
    @optons = options
    admin_by_display_name
    process_community_admin!
  end

  private

  def get_id
    last_id = CommunityAdmin.order(:id).pluck(:id).last
    (last_id || 0) + 1
  end

  def admin_by_display_name
    @admin_acc = Account.find_by(display_name: @optons[:display_name], username: @optons[:username])
  end

  def community_admin_attribute
    {
      id: get_id,
      account_id: admin_by_display_name.id,
      patchwork_community_id: @optons[:community_id]
    }.compact
  end

  def process_community_admin!
    @community_admin = @admin_acc&.community_admins&.find_or_create_by(community_admin_attribute)
    @community_admin&.save!
  end
end
