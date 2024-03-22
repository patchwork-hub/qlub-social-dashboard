class GlobalFiltersController < ApplicationController
  load_and_authorize_resource

  def index
    respond_to do |format|
      format.html
      format.json {render json: prepare_filters_for_datatable}
    end
  end

  def create
    @global_filter.account = current_user.account
    if @global_filter.save
      redirect_to global_filters_url, notice: 'A filter keyword was successfully created!'
    else
      flash[:error] = @global_filter.errors.full_messages
      render :new
    end
  end

  def update
    if @global_filter.update(global_filter_params)
      redirect_to global_filters_url, notice: 'A filter keyword was successfully updated!'
    else
      flash[:error] = @global_filter.errors.full_messages
      render :edit
    end
  end

  def destroy
    @global_filter.destroy
    redirect_to global_filters_url, notice: 'A filter keyword was successfully destroyed!'
  end

  private

    def global_filter_params
      params.require(:global_filter).permit(:account_id, :keyword, :is_filter_hashtag)
    end

    def prepare_filters_for_datatable
      @global_filters = @all = GlobalFilter.all.where(community_id: nil)

      @global_filters = @global_filters.where("keyword like :q", q: "%#{@q}%") if @q.present?

      @global_filters = @global_filters.order("#{@sort}": :"#{@dir}").page(@page).per(@per)
      
      @data = @global_filters.each_with_object([]) { |g, arr|
        arr << {
          keyword: g.keyword,
          is_filter_hashtag: g.is_filter_hashtag? ? 'Yes' : 'No',
          actions: "
                    <a href='#{edit_global_filter_url(g.id)}' title='edit keyword' class='mr-2'><i class='fa-solid fa-pen-to-square'></i></a>
                    <a href='#{global_filter_url(g.id)}' title='delete keyword' class='mr-2' data-confirm='Are you sure?' rel='nofollow' data-method='delete'><i class='fa-solid fa-trash-can'></i></a>
                   "
        }
      }

      total_records  = @all.size
      total_filtered = @q.present? ? @global_filters.total_count : total_records

      {draw: params[:draw], recordsTotal: total_records, recordsFiltered: total_filtered, data: @data}
    end
end