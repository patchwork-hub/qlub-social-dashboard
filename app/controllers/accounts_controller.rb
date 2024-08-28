class AccountsController < BaseController
  before_action :find_account, only: [:follow, :unfollow]

  def show; end

  def follow
    follow = FollowService.new.call(current_user.account, @account)
    render json: { message: 'successfully_followed' }, status: :ok
  end

  def unfollow
    follow = UnfollowService.new.call(current_user.account, @account)
    render json: { message: 'successfully_unfollowed' }, status: :ok
  end

  def find_account
    @account = Account.find(params[:id])
  end

  def records_filter
    @filter = Filter::Account.new(params)
  end
end
