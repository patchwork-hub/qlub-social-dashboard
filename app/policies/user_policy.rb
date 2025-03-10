class UserPolicy < ApplicationPolicy
  def login?
    user&.role&.name.in?(%w[MasterAdmin OrganisationAdmin UserAdmin HubAdmin])
  end

  def master_admin?
    user&.role&.name.in?(%w[MasterAdmin])
  end

  def organisation_admin?
    user&.role&.name.in?(%w[OrganisationAdmin])
  end

  def user_admin?
    user&.role&.name.in?(%w[UserAdmin])
  end

  def hub_admin?
    user&.role&.name.in?(%w[HubAdmin])
  end

  def user_is_not_community_admin?
    (organisation_admin? || user_admin? || hub_admin?) && !CommunityAdmin.exists?(account_id: user.account_id)
  end
end
