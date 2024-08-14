class AccountsController < BaseController

  def show
    respond_to do |format|
      format.html.haml { render partial: 'follows/search_result', locals: { records: @records } }
    end
  end

  protected

  def records_filter
    @filter = Filter::Follows.new(params)
  end
end