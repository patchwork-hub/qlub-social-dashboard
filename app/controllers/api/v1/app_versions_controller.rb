module Api
  module V1
    class AppVersionsController < ApiController
			skip_before_action :verify_key!
			before_action :authenticate_user_from_header
			before_action :set_app_version, only: %i[check_version]

			def check_version
				return render_not_found unless @app_version
		
				app_version_history = AppVersionHistory.where(
					app_version_id: @app_version.id,
					os_type: params[:os_type]
				).last
				app_version_history.present? ? render(json: { data: app_version_history }) : render_not_found	
			end
		
			private
		
			def set_app_version
				@app_version = AppVersion.find_by(version_name: params[:current_app_version])
			end
		
			def render_not_found
				render json: { error: "Record not found" }, status: 404
			end
		end
	end
end
