class KeywordFiltersController < ApplicationController
  load_and_authorize_resource
  before_action :set_keyword_filter, only: [:update, :destroy]

  def index
    respond_to do |format|
      format.html
      format.json { render json: prepare_filters }
      format.csv {
        send_data KeywordFilter.all.to_csv(
          [
            'keyword',
            'is_active',
            'server_setting_id',
            'filter_type'
          ]
        )
      }
    end
  end

  def create
    @keyword_filter = KeywordFilter.new(keyword_filter_params)
    respond_to do |format|
      if @keyword_filter.save
        format.html { redirect_back(fallback_location: root_path, flash: { success: 'A filter keyword was successfully created!' }) }
        format.json { render json: @keyword_filter, status: :created }
      else
        format.html { redirect_back(fallback_location: root_path, flash: { error: @keyword_filter.errors.full_messages }) }
        format.json { render json: { errors: @keyword_filter.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @keyword_filter.update(keyword_filter_params)
        format.html { redirect_back(fallback_location: root_path, notice: 'A filter keyword was successfully updated!') }
        format.json { render json: @keyword_filter, status: :ok }
      else
        format.html { redirect_back(fallback_location: root_path, flash: { error: @keyword_filter.errors.full_messages }) }
        format.json { render json: { errors: @keyword_filter.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @keyword_filter.destroy
    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path, flash: { success: 'A filter keyword was successfully destroyed!' }) }
      format.json { head :no_content }
    end
  end

  private

  def set_keyword_filter
    @keyword_filter = KeywordFilter.find(params[:id])
  end

  def keyword_filter_params
    params.require(:keyword_filter).permit(:keyword, :filter_type, :server_setting_id, :is_active)
  end

  def prepare_filters
    @keyword_filters = @all = KeywordFilter.all

    @keyword_filters = @keyword_filters.where("keyword like :q", q: "%#{@q}%") if @q.present?

    @keyword_filters = @keyword_filters.order("#{@sort}": :"#{@dir}").page(@page).per(@per)

    @data = @keyword_filters.each_with_object([]) { |g, arr|
      arr << {
        server_setting_id: g.server_setting&.name,
        keyword: g.keyword,
        is_active: g.is_active? ? 'Yes' : 'No',
        filter_type: g.filter_type
      }
    }

    total_records  = @all.size
    total_filtered = @q.present? ? @keyword_filters.total_count : total_records

    { draw: params[:draw], recordsTotal: total_records, recordsFiltered: total_filtered, data: @data }
  end
end
