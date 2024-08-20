class FollowsController < BaseController
  def index
    @records = load_records
    @search = records_filter.build_search
    respond_to do |format|
      format.html { render partial: 'follows/search_result', locals: { records: @records } }
    end
  end  

  protected

  def records_filter
    @filter = Filter::Follow.new(params)
  end
end