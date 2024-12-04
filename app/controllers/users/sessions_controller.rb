# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  require 'httparty'

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
    # Revoke the access token from Mastodon
    revoke_access_token(cookies[:access_token])

    # Clear the access token cookie
    cookies.delete(:access_token, domain: Rails.env.development? ? :all : '.channel.org')
    super
  end

  protected

  def after_sign_in_path_for(resource)
    if resource.master_admin?
      root_path
    else
      communities_path
    end
  end

  private


  def revoke_access_token(token)
    return unless token

    begin
      url = Rails.env.development? ? 'http://localhost:3000/oauth/revoke' : 'https://channel.org/oauth/revoke'

      HTTParty.post(
        url,
        body: { 
          token: token,
          client_id: "7Xn_TbJq9D5uWhT_sL9Te9yXAJ26UrxSlXtBoKT7rt0",
          client_secret: "5yf68rGhPsxPuSQd2RMHZ8tHV02GPIYOV5fT88V07o8"
        },
        headers: { 'Authorization': "Bearer #{token}" }
      )
    rescue HTTParty::Error => e
      Rails.logger.error "Failed to revoke access token: #{e.message}"
    end
  end
end
