class CommunityAdminsController < ApplicationController
  load_and_authorize_resource
  before_action :set_community, only: %i[ new create ]
  before_action :get_user_role, only: %i[ create ]

  def show
    
  end

  def new; end

  def create
    if @user_role.present?
      create_account
      create_user

      if @admin = CommunityAdmin.find_or_create_by(user: @user, community: @community)
        redirect_to @admin, notice: 'A Community Admin was successfully created!'
      else
        flash[:error] = @admin.errors.to_a
        render :new
      end
    else
      flash[:error] = 'User role is required!'
      render :new
    end
  end


  def edit; end

  def update
    account_update_params = {display_name: admin_params[:display_name], username: admin_params[:username]}
    user_update_params    = {email: admin_params[:email]}
    
    if admin_params[:password].present?
      user_update_params[:password] = admin_params[:password]
    end

    if @community_admin.user.update(user_update_params) && @community_admin.user.account.update(account_update_params)
      redirect_to @community_admin, notice: 'The Community Admin was successfully updated!'
    else
      flash[:error] = @community_admin.errors.to_a
      render :edit
    end
  end


  private

    def set_community
      @community = Community.find_by(slug: params[:community_id])
      raise ActiveRecord::RecordNotFound unless @community
    end

    def get_user_role
      if ['community-admin', 'rss-account'].include?(params[:user_role])
        @user_role = params[:user_role]
      end
    end
    
    def admin_params
      params.permit(:display_name, :username, :email, :password, :community_id)
    end

    def create_account
      @account = Account.where(username: admin_params[:username]).first_or_initialize(username: admin_params[:username], display_name: admin_params[:display_name])

      @account.save!(validate: false)
    end

    def create_user
      role = UserRole.find_or_create_by(name: @user_role)

      @user = User.where(email: admin_params[:email])
                  .first_or_initialize(
                    email: admin_params[:email], 
                    password: admin_params[:password],
                    password_confirmation: admin_params[:password], 
                    confirmed_at: Time.zone.now, 
                    role: role, 
                    account: @account,
                    approved: true
                  )
      @user.save!
    end
end