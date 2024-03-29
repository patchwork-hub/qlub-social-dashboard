class ServerSettingController < ApplicationController
  # load_and_authorize_resource class: 'EndPoint'

  def index
    respond_to do |format|
      format.html
      format.json { render json: prepare_server_setting_for_datatable }
    end
  end

  private

  def prepare_server_setting_for_datatable
    @server_setting_data = {
      "Spam Block" => [
        { name: "Spam filters", value: true },
        { name: "Sign up challenge", value: false }
      ],
      "Content Moderation" => [
        { name: "Content filters", value: true },
        { name: "Live blocklist", value: true }
      ],
      "Federation" => [
        { name: "Bluesky", value: false },
        { name: "Threads", value: true }
      ],
      "Local Features" => [
        { name: "Custom theme", value: true },
        { name: "Search opt-out", value: true },
        { name: "Local only posts", value: true },
        { name: "Long posts and Markdown", value: true },
        { name: "Local quote posts", value: true },
      ],
      "User Management" => [
        { name: "Guest Accounts", value: true },
        { name: "e-Newsletters", value: true },
        { name: "Analytics", value: true }
      ],
      "Plug-ins" => []
    }

    if @q.present?
      @server_setting_data = @server_setting_data.where(" lower(end_points.name) like :q",
                                q: "%#{@q.downcase}%"
                              )
    end
    
    # @server_setting_data   = @server_setting_data.order("#{@sort}": :"#{@dir}").page(@page).per(@per)                  

    @data = @server_setting_data.map do |category, settings|
      {
        name: category,
        settings: settings.map do |setting|
          {
            name: setting[:name],
            is_operational: setting[:value]
          }
        end,
        created_at: Time.now.strftime('%b %d, %Y - %H:%M %p')
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
