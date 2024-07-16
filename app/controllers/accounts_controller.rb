class AccountsController < BaseController
  def index
    @accounts = load_accounts
    @search = account_filter.bulid_search
  end

  def show; end

  protected 

  def load_accounts
    account_filter.get
  end

  def account_filter
    @filter = Filter::Account.new(params)
  end
end

