class KeywordFiltersController < ApplicationController
  load_and_authorize_resource

  def index
    respond_to do |format|
      format.html
      format.json {render json: prepare_filters_for_datatable}
    end
  end

  def create
    if @keyword_filter.save
      redirect_to keyword_filters_url, notice: 'A filter keyword was successfully created!'
    else
      flash[:error] = @keyword_filter.errors.full_messages
      render :new
    end
  end

  def update
    if @keyword_filter.update(keyword_filter_params)
      redirect_to keyword_filters_url, notice: 'A filter keyword was successfully updated!'
    else
      flash[:error] = @keyword_filter.errors.full_messages
      render :edit
    end
  end

  def destroy
    @keyword_filter.destroy
    redirect_to keyword_filters_url, notice: 'A filter keyword was successfully destroyed!'
  end

  private

    def keyword_filter_params
      params.require(:keyword_filter).permit(:account_id, :keyword, :is_filter_hashtag, :server_setting_id, :is_active, :is_custom_filter)
    end

    def prepare_filters_for_datatable
      @keyword_filters = @all = KeywordFilter.all

      @keyword_filters = @keyword_filters.where("keyword like :q", q: "%#{@q}%") if @q.present?

      @keyword_filters = @keyword_filters.order("#{@sort}": :"#{@dir}").page(@page).per(@per)
      
      @data = @keyword_filters.each_with_object([]) { |g, arr|
        arr << {
          server_setting_id: g.server_setting.name,
          keyword: g.keyword,
          is_active: g.is_active? ? 'Yes' : 'No',
          is_custom_filter: g.is_custom_filter? ? 'Yes' : 'No',
          is_filter_hashtag: g.is_filter_hashtag? ? 'Yes' : 'No',
          actions: "
                    <a href='#{edit_keyword_filter_url(g.id)}' title='edit keyword' class='mr-2'><i class='fa-solid fa-pen-to-square'></i></a>
                    <a href='#{keyword_filter_url(g.id)}' title='delete keyword' class='mr-2' data-confirm='Are you sure?' rel='nofollow' data-method='delete'><i class='fa-solid fa-trash-can'></i></a>
                   "
        }
      }

      total_records  = @all.size
      total_filtered = @q.present? ? @keyword_filters.total_count : total_records

      {draw: params[:draw], recordsTotal: total_records, recordsFiltered: total_filtered, data: @data}
    end
end