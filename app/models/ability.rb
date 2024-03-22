# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.owner?
    can :manage, :all
  end
end
