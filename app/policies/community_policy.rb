# app/policies/community_policy.rb
class CommunityPolicy < ApplicationPolicy
  def initialize_form?
    master_admin? || user_has_access_to_community?
  end

  def index?
    initialize_form?
  end

  def step1?
    initialize_form?
  end

  def step1_save?
    initialize_form?
  end

  def step2?
    initialize_form?
  end

  def step2_save?
    initialize_form?
  end

  def step2_update_admin?
    initialize_form?
  end

  def step3?
    initialize_form?
  end

  def step3_save?
    initialize_form?
  end

  def step3_update_hashtag?
    initialize_form?
  end

  def step3_delete_hashtag?
    initialize_form?
  end

  def step4?
    initialize_form?
  end

  def step4_save?
    initialize_form?
  end

  def step5?
    not_user_admin?
  end

  def step5_save?
    step5?
  end

  def step5_update?
    step5?
  end

  def step5_delete?
    step5?
  end

  def step6?
    step5?
  end

  def step6_rule_create?
    step5?
  end

  def manage_additional_information?
    step5?
  end

  def set_visibility?
    step5?
  end

  private

  def user_has_access_to_community?
    return false unless user.present? && record.present?

    CommunityAdmin.exists?(patchwork_community_id: record.id, account_id: user.account_id)
  end

  def not_user_admin?
    master_admin? || organisation_admin?
  end
end
