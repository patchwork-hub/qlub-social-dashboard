class AccountsController < BaseController
  
  def show; end

  protected 

  def records_filter
    @filter = Filter::Account.new(params)
  end
end

