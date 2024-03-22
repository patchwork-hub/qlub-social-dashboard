class TimelinesStatusController < ApplicationController
  load_and_authorize_resource class: 'EndPoint'

  def index
    respond_to do |format|
      format.html
      format.json { render json: prepare_timelines_status_for_datatable }
    end
  end

  private

  def prepare_timelines_status_for_datatable
    @monitoring_data = EndPoint.joins(:monitoring_statuses)
                        .select("end_points.name, monitoring_statuses.is_operational, monitoring_statuses.created_at")
                        .where(
                          "monitoring_statuses.created_at = (
                            SELECT MAX(created_at)
                            FROM monitoring_statuses
                            WHERE monitoring_statuses.end_point_id = end_points.id
                          )"
                        )

    if @q.present?
      @monitoring_data = @monitoring_data.where(" lower(end_points.name) like :q",
                                q: "%#{@q.downcase}%"
                              )
    end
    @monitoring_data   = @monitoring_data.order("#{@sort}": :"#{@dir}").page(@page).per(@per)                  

    @data = @monitoring_data.each_with_object([]) { |r, arr|
      arr << {
        name: r.name,
        is_operational: r.is_operational ? "<i class='fa fa-check' style='color: green;'></i>" : "<i class='fa fa-times' style='color: red;'></i>",
        created_at: r.created_at.strftime('%b %d, %Y - %H:%M %p')
      }
    }

    {
      draw: params[:draw],
      recordsTotal: @data.size,
      recordsFiltered: @data.size,
      data: @data
    }
  end
end
