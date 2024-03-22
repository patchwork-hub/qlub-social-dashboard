class AppVersionsController < ApplicationController
  respond_to :html, :json
  
  load_and_authorize_resource except: [:deprecate]
  skip_before_action :verify_authenticity_token, only: [:deprecate]

  def index
    respond_to do |format|
      format.html
      format.json {render json: prepare_app_versions_for_datatable}
    end
  end

  def create
    payload      = version_params
    version_name = payload.delete :version_name
    @app_version = AppVersion.new(version_name: version_name)
    if @app_version.save
      if payload[:os_type] == 'both'
        AppVersionHistory.create(app_version: @app_version, os_type: 'android', link_url: payload[:link_url], deprecated: false)
        AppVersionHistory.create(app_version: @app_version, os_type: 'ios', deprecated: false)
      else
        AppVersionHistory.create(app_version: @app_version, os_type: payload[:os_type], link_url: payload[:link_url], deprecated: false)
      end
      redirect_to app_versions_url, notice: 'A App Version was successfully created!'
    else
      flash[:error] = @app_version.errors.full_messages
      render :index
    end
  end

  def deprecate
    @history = AppVersionHistory.find(params[:id])
    @history.update(deprecated: !@history.deprecated)
    render json: {message: 'success'}, status: 200
  end

  private

    def version_params
      params.permit(:version_name, :os_type, :link_url)
    end

    def prepare_app_versions_for_datatable
      @all            = AppVersion.all


      @app_versions   = @all

      @app_versions = @app_versions.where("version_name like :q", q: "%#{@q}%") if @q.present?

      @app_versions   = @app_versions.order("#{@sort}": :"#{@dir}").page(@page).per(@per)
      
      @data = @app_versions.each_with_object([]) { |v, arr|
        @for_android = @android_deprecated = @android_history_id = @apk_download_link = @for_ios = @ios_deprecated = @ios_history_id = nil
        v.app_version_histories.each do |h|
          if h.os_type == 'android'
            @for_android        = true
            @android_deprecated = h.deprecated
            @android_history_id = h.id
            @apk_download_link  = h.link_url
          elsif h.os_type == 'ios'
            @for_ios        = true
            @ios_deprecated = h.deprecated
            @ios_history_id = h.id
          end

        end
        arr << {
          version_name: v.version_name,
          for_android: @for_android ? '✅' : '-',
          android_deprecated: @for_android ? "<input type='checkbox' class='form-check deprecate-version-checkbox' value='#{@android_history_id}' id='version-#{@android_history_id}' #{@android_deprecated ? 'checked' : ''}>" : '-',
          for_ios: @for_ios ? '✅' : '-',
          ios_deprecated: @for_ios ? "<input type='checkbox' class='form-check deprecate-version-checkbox' value='#{@ios_history_id}' id='version-#{@ios_history_id}' #{@ios_deprecated ? 'checked' : ''}>" : '-',
          apk_download_link: @apk_download_link.present? ? "<a href='#{@apk_download_link}' target='_blank'>Download" : '-'
        }
      }

      total_records  = @all.size
      total_filtered = @q.present? ? @app_versions.total_count : total_records

      {draw: params[:draw], recordsTotal: total_records, recordsFiltered: total_filtered, data: @data}
    end

    def set_app_version
      @app = AppVersion.find_by(version_name: params[:id]) if params[:id].present?
    end

end