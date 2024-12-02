# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token, only: [:destroy]

  def new
    super
  end

  def create
    self.resource = warden.authenticate!(auth_options)

    if resource.persisted? && !policy(resource).login?
      sign_out(resource)
      flash[:error] = "You are not authorized to log in."
      Rails.logger.debug("Flash message: #{flash[:error]}")
      redirect_to new_user_session_path and return
    end

    super do |resource|
      if resource.persisted?
        sign_in(resource)
      end
    end
  end

  def destroy
    super
  end
end
