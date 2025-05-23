# app/policies/application_policy.rb
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    master_admin?
  end

  def show?
    master_admin?
  end

  def create?
    master_admin?
  end

  def new?
    create?
  end

  def update?
    master_admin?
  end

  def edit?
    update?
  end

  def destroy?
    master_admin?
  end

  private

  def master_admin?
    user&.role&.name.in?(%w[MasterAdmin])
  end

  def organisation_admin?
    user&.role&.name.in?(%w[OrganisationAdmin])
  end

  def user_admin?
    user&.role&.name.in?(%w[UserAdmin])
  end

  def newsmast_admin?
    user&.role&.name.in?(%w[NewsmastAdmin])
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NoMethodError, "You must define #resolve in #{self.class}"
    end

    private

    attr_reader :user, :scope
  end
end
