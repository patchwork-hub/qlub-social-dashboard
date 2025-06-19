# frozen_string_literal: true

module Api
  module V1
    class SettingsController < ApiController
      skip_before_action :verify_key!
      before_action :authenticate_and_set_account
      before_action :validate_and_set_app_name
      before_action :set_setting, only: [:destroy]

      def index
        @setting = Setting.find_by(account: @account, app_name: @app_name)

        if @setting
          render json: { data: @setting }
        else
          render json: { data: default_setting }, status: 200
        end
      end

      def upsert
        @setting = Setting.find_or_initialize_by(account: @account, app_name: @app_name)

        if @setting.update(setting_params)
          render json: { message: 'Settings have been saved successfully.' }, status: 200
        else
          render json: { errors: @setting.errors.to_hash }, status: 422
        end
      end

      def destroy
        if @setting.destroy
          head :no_content
        else
          render json: { errors: { base: 'Failed to delete settings.' } }, status: 422
        end
      end

      private

      def set_setting
        @setting = Setting.find_by(account: @account, app_name: @app_name)
        render json: { error: 'Settings not found.' }, status: 404 unless @setting
      end

      def authenticate_and_set_account
        if request.headers['Authorization'].present? && params[:instance_domain].present?
          validate_mastodon_account
          @account = current_remote_account
        else
          authenticate_user_from_header
          @account = current_account
        end
      rescue AuthenticationError => e
        render json: { error: 'Authentication failed: ' + e.message }, status: 401
      end

      def validate_and_set_app_name
        app_name_param = params[:app_name]
        if app_name_param.blank?
          @app_name = Setting.column_defaults['app_name']
        elsif Setting.app_names.key?(app_name_param)
          @app_name = app_name_param
        else
          render json: {
            errors: { app_name: "'#{app_name_param}' is not a valid app_name. Valid options are: #{Setting.app_names.keys.join(', ')}" }
          }, status: 400
        end
      end

      def setting_params
        params.permit(settings: [theme: [:type]])
      end

      def default_setting
        {
          app_name: @app_name,
          account_id: @account.id,
          settings: {
            theme: {
              type: setting_params.present? ? setting_params[:settings][:theme][:type] || nil : nil
            }
          }
        }.compact
      end
    end
  end
end
