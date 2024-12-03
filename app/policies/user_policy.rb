class UserPolicy < ApplicationPolicy
  def login?
    user&.role&.name.in?(%w[MasterAdmin OrganizationAdmin UserAdmin])
  end

  def master_admin?
    user&.role&.name.in?(%w[MasterAdmin])
  end

  def master_or_organization_admin?
    user&.role&.name.in?(%w[MasterAdmin OrganizationAdmin])
  end
end
