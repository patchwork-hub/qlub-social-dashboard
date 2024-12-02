class UserPolicy < ApplicationPolicy
  def login?
    user&.role&.name.in?(%w[MasterAdmin OrganizationAdmin])
  end

  def master_admin?
    user&.role&.name.in?(%w[MasterAdmin])
  end
end
