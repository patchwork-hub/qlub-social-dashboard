class AccountsController < BaseController
  before_action :find_account, only: [:follow, :unfollow]
  before_action :find_admin, only: [:follow, :unfollow]

  def show; end

  def follow
    FollowService.new.call(@admin, @account)
    render json: { message: 'successfully_followed' }, status: :ok
  end

  def unfollow
    UnfollowService.new.call(@admin, @account)
    render json: { message: 'successfully_unfollowed' }, status: :ok
  end

  def find_account
    @account = Account.find(params[:id])
  end

  def find_admin
    community = Community.find(params[:community_id])
    account_name = "#{community.slug.underscore}_channel"
    @admin = Account.where(username: account_name).first
  end

  def records_filter
    @filter = Filter::Account.new(params)
  end
end
