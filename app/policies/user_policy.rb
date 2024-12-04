class UserPolicy < ApplicationPolicy
  def login?
    user&.role&.name.in?(%w[MasterAdmin OrganisationAdmin UserAdmin])
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
end
