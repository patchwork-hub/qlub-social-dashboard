# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token, only: [:destroy]

  def new
    super
  end

  def create
    super do |resource|
      # We only need to call this if this hasn't already been
      # called from one of the two-factor or sign-in token
      # authentication methods

      on_authentication_success(resource, :password) unless @on_authentication_success_called
    end
  end

  def destroy
    super
  end

  protected

    def on_authentication_success(user, security_measure)
      @on_authentication_success_called = true
      sign_in(user)
    end

end
