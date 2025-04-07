class AppVersionsController < ApplicationController
  before_action :authorize_master_admin!
  before_action :set_app_version, only: %i[destroy]
  
  PER_PAGE = 10

  def index
    @search = AppVersion.ransack(params[:q])
    @app_versions = @search.result.order(created_at: :asc).page(params[:page]).per(PER_PAGE)
  end

  def new
    @app_version = AppVersion.new
  end

  def create
    payload      = app_version_params
    version_name = payload.delete :version_name
    @app_version = AppVersion.new(version_name: version_name)
    if @app_version.save
      if params[:os_type] == 'both'
        AppVersionHistory.create(app_version: @app_version, os_type: 'android', deprecated: false)
        AppVersionHistory.create(app_version: @app_version, os_type: 'ios', deprecated: false)
      else
        AppVersionHistory.create(app_version: @app_version, os_type: params[:os_type], deprecated: false)
      end
      redirect_to app_versions_url, notice: 'An App version was successfully created!'
    else
      flash[:error] = @app_version.errors.full_messages
      render :new
    end
  end

  def update
    if @app_version.update(app_version_params)
      redirect_to @app_version, notice: 'App version was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @app_version.destroy
    redirect_to app_versions_url, notice: 'App version was successfully destroyed.'
  end

  def deprecate
    @history = AppVersionHistory.find(params[:id])
    @history.update(deprecated: !@history.deprecated)
    render json: {message: 'success'}, status: 200
  end

  def authorize_master_admin!
    authorize :master_admin, :index?
  end

  private

  def set_app_version
    @app_version = AppVersion.find(params[:id])
  end

  def app_version_params
    params.require(:app_version).permit(:version_name)
  end
end
