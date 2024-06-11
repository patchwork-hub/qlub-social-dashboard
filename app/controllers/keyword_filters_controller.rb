class KeywordFiltersController < ApplicationController
  load_and_authorize_resource
  before_action :set_keyword_filter_group
  before_action :set_keyword_filter, only: [:edit, :update, :destroy]

  def index
    respond_to do |format|
      format.html
      format.json { render json: prepare_filters }
      format.csv {
        send_data KeywordFilter.all.to_csv(
          [
            'keyword',
            'keyword_filter_group_id',
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

  def edit
  end

  def update
    respond_to do |format|
      KeywordFilterGroup.transaction do
        if @keyword_filter_group.update(keyword_filter_group_params) && @keyword_filter.update(keyword_filter_params)
          format.html { redirect_to @keyword_filter_group, notice: 'Keyword filter and group were successfully updated.' }
          format.json { render json: @keyword_filter, status: :ok }
        else
          format.html { render :edit }
          format.json { render json: { errors: @keyword_filter.errors.full_messages + @keyword_filter_group.errors.full_messages }, status: :unprocessable_entity }
        end
      end
    end
  end

  def destroy
    @keyword_filter.destroy
    respond_to do |format|
      format.html { redirect_to @keyword_filter_group, notice: 'Keyword filter and group were successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private

  def set_keyword_filter_group
    @keyword_filter_group = KeywordFilterGroup.find(params[:keyword_filter_group_id])
  end

  def set_keyword_filter
    @keyword_filter = @keyword_filter_group.keyword_filters.find(params[:id])
  end

  def keyword_filter_params
    params.require(:keyword_filter).permit(:keyword, :filter_type, :keyword_filter_group_id)
  end

  def keyword_filter_group_params
    params.require(:keyword_filter_group).permit(:name)
  end

  def prepare_filters
    @keyword_filters = @all = KeywordFilter.all

      @keyword_filters = @keyword_filters.order("#{@sort}": :"#{@dir}").page(@page).per(@per)

      @data = @keyword_filters.each_with_object([]) { |g, arr|
        arr << {
          keyword: g.keyword,
          keyword_filter_group_id: KeywordFilterGroup.find_by_id(g.keyword_filter_group_id)&.name,
          filter_type: g.filter_type
        }
      }

    total_records  = @all.size
    total_filtered = @q.present? ? @keyword_filters.total_count : total_records

    { draw: params[:draw], recordsTotal: total_records, recordsFiltered: total_filtered, data: @data }
  end
end
