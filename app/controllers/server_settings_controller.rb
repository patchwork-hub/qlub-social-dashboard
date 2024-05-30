class ServerSettingsController < ApplicationController
  load_and_authorize_resource class: 'ServerSetting'
  before_action :set_keyword_filter, only: [:index]

  def index
    @server_settings = prepare_server_setting
  end

  def update
    @server_setting = ServerSetting.find(params[:id])
    if @server_setting.update(server_setting_params)
      render json: { success: true, message: 'Server setting updated successfully' }
    else
      render json: { success: false, error: 'Failed to update server setting' }, status: :unprocessable_entity
    end
  end

  private

  def set_keyword_filter
    @keyword_filter = KeywordFilter.new
  end

  def server_setting_params
    params.require(:server_setting).permit(:value) # Permit only the 'value' parameter
  end

  def prepare_server_setting
    @parent_settings = ServerSetting.where(parent_id: nil).includes(:children).order(:id)

    @parent_settings = @parent_settings.where("lower(name) LIKE ?", "%#{@q.downcase}%") if @q.present?

    @data = @parent_settings.map do |parent_setting|
      {
        name: "#{parent_setting.name}",
        settings: parent_setting.children.sort_by(&:position).map do |child_setting|
          {
            id: child_setting.id,
            name: child_setting.name,
            is_operational: child_setting.value,
            keyword_filters: child_setting.keyword_filters.map do |keyword|
              {
                id: keyword.id,
                keyword: keyword.keyword,
                is_active: keyword.is_active,
                filter_type: keyword.filter_type
              }
            end
          }
        end
      }
    end

    @data
  end
end
