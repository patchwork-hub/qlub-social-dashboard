class ServerSettingsController < ApplicationController
  load_and_authorize_resource class: 'ServerSetting'

  before_action :set_server_setting, only: [:edit, :update, :destroy]

  def index
    respond_to do |format|
      format.html
      format.json { render json: prepare_server_setting_for_datatable }
    end
  end

  def new
    @server_setting = ServerSetting.new
  end

  def create
    @server_setting = ServerSetting.new(server_setting_params)
    if @server_setting.save
      redirect_to server_settings_url, notice: 'A Server Setting was successfully created!'
    else
      flash[:error] = @server_setting.errors.full_messages
      render :new
    end
  end

  def edit
  end

  def update
    if @server_setting.update(server_setting_params)
      redirect_to server_settings_url, notice: 'A server setting was successfully updated!'
    else
      flash[:error] = @server_setting.errors.full_messages
      render :edit
    end
  end

  def destroy
    @server_setting.destroy
    redirect_to server_settings_url, notice: 'Server setting was successfully destroyed.'
  end

  def get_child_count
    parent_id = params[:parentId]
    if parent_id.present?
      parent_setting = ServerSetting.find(parent_id)
      child_count = parent_setting.children.count
      render json: { childCount: child_count }
    else
      render json: { error: 'Parent ID is missing' }, status: :unprocessable_entity
    end
  end

  private

  def server_setting_params
    params.require(:server_setting).permit(:name, :value, :parent_id, :position)
  end


  def set_server_setting
    @server_setting = ServerSetting.find(params[:id])
  end

  def prepare_server_setting_for_datatable
    @parent_settings = ServerSetting.where(parent_id: nil).includes(:children).order(:id)
  
    @parent_settings = @parent_settings.where("lower(name) LIKE ?", "%#{@q.downcase}%") if @q.present?
  
    @parent_settings = @parent_settings.order("#{@sort}": :"#{@dir}").page(@page).per(@per)
  
    @data = @parent_settings.map do |parent_setting|
      {
        name: "<a href='#{edit_server_setting_url(parent_setting)}' title='edit keyword'>#{parent_setting.name}</a>",
        settings: parent_setting.children.sort_by(&:position).map do |child_setting|
          {
            name: "<a href='#{edit_server_setting_url(child_setting)}' title='edit keyword'>#{child_setting.name}</a>",
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
