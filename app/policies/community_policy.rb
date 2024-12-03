# app/policies/community_policy.rb
class CommunityPolicy < ApplicationPolicy
  def index?
    user.present? && (user.role.name == 'MasterAdmin' || related_community_admin?)
  end

  def step1?
    can_manage_community?
  end

  def step1_save?
    can_manage_community?
  end

  def step2?
    can_manage_community?
  end

  def step2_save?
    can_manage_community?
  end

  def step2_update_admin?
    can_manage_community?
  end

  def step3?
    can_manage_channel?
  end

  def step3_save?
    can_manage_channel?
  end

  def step3_update_hashtag?
    can_manage_channel?
  end

  def step3_delete_hashtag?
    can_manage_channel?
  end

  def step4?
    can_manage_channel?
  end

  def step4_save?
    can_manage_channel?
  end

  def step5?
    can_manage_channel?
  end

  def step5_save?
    can_manage_channel?
  end

  def step5_update?
    can_manage_channel?
  end

  def step5_delete?
    can_manage_channel?
  end

  def step6?
    can_manage_channel?
  end

  def step6_rule_create?
    can_manage_channel?
  end

  def manage_additional_information?
    can_manage_community?
  end

  def set_visibility?
    can_manage_community?
  end

  private

  def can_manage_community?
    user.has_role?(:MasterAdmin) || user.has_role?(:OrganizationAdmin)
  end

  def can_manage_channel?
    user.has_role?(:MasterAdmin) || user.has_role?(:OrganizationAdmin) || user.has_role?(:UserAdmin)
  end

  def related_community_admin?
    CommunityAdmin.exists?(account_id: user.account_id)
  end
end
