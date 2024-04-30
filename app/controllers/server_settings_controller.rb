class ServerSettingsController < ApplicationController
  load_and_authorize_resource class: 'ServerSetting'

  def index
    respond_to do |format|
      format.html
      format.json { render json: prepare_server_setting_for_datatable }
    end
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

  def server_setting_params
    params.require(:server_setting).permit(:value) # Permit only the 'value' parameter
  end

  def prepare_server_setting_for_datatable
    @parent_settings = ServerSetting.where(parent_id: nil).includes(:children).order(:id)
  
    @parent_settings = @parent_settings.where("lower(name) LIKE ?", "%#{@q.downcase}%") if @q.present?
  
    @parent_settings = @parent_settings.order("#{@sort}": :"#{@dir}").page(@page).per(@per)
  
    @data = @parent_settings.map do |parent_setting|
      {
        name: "#{parent_setting.name}",
        settings: parent_setting.children.sort_by(&:position).map do |child_setting|
          {
            id: child_setting.id,
            name: child_setting.name,
            is_operational: child_setting.value
          }
        end
      }
    end
  
    {
      draw: params[:draw],
      recordsTotal: @data.size,
      recordsFiltered: @data.size,
      data: @data
    }
  end  
end
