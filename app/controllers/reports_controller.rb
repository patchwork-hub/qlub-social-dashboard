class ReportsController < ApplicationController
  load_and_authorize_resource

  def index
    respond_to do |format|
      format.html
      format.json {render json: prepare_reports_for_datatable}
    end
  end

  def show; end

  private

    def prepare_reports_for_datatable
      @all       = Report.select('
                          reports.id, statuses.id as status_id, 
                          statuses.text, reporter.display_name as reporter_name, 
                          reporter.username as reporter_username, 
                          owner.display_name as owner_name, owner.username as owner_username'
                          )
                         .joins('INNER JOIN statuses ON statuses.id = ANY(reports.status_ids)')
                         .joins('INNER JOIN accounts as reporter ON reporter.id = reports.account_id')
                         .joins('INNER JOIN accounts as owner  ON owner.id = reports.target_account_id')

      @reports   = @all
      if @q.present?
        @reports = @reports.where(" lower(owner.display_name) like :q
                                  OR lower(owner.username) like :q
                                  OR lower(reporter.display_name) like :q
                                  OR lower(reporter.username) like :q
                                  OR lower(statuses.text) like :q",
                                  q: "%#{@q.downcase}%"
                                )
      end
      @reports   = @reports.order("#{@sort}": :"#{@dir}").page(@page).per(@per)
      
      @data = @reports.each_with_object([]) { |r, arr|
        arr << {
          text:   r.text&.truncate(50, separator: ' '),
          owner_name: r.owner_name.presence || '-',
          owner_username: r.owner_username,
          reporter_name: r.reporter_name.presence || '-',
          reporter_username: r.reporter_username,
          actions: "
                    <a href='#{report_url(r.id)}' title='view report' class='mr-2'><i class='fa-solid fa-eye'></i></a>
                  "
        }
      }

      total_records  = @all.size
      total_filtered = @q.present? ? @reports.total_count : total_records

      {draw: params[:draw], recordsTotal: total_records, recordsFiltered: total_filtered, data: @data}
    end

end