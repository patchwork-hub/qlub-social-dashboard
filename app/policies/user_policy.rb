class UserPolicy < ApplicationPolicy
  def login?
    user&.role&.name.in?(%w[MasterAdmin OrganizationAdmin UserAdmin])
  end

  def master_admin?
    user&.role&.name.in?(%w[MasterAdmin])
  end

  def organization_admin?
    user&.role&.name.in?(%w[OrganizationAdmin])
  end

  def user_admin?
    user&.role&.name.in?(%w[UserAdmin])
  end
end
