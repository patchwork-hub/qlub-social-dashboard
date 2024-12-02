class CommunityAdminsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_community!

  def index
  end

  def show
  end

  def new
  end

  def create
    @community_admin = @community.community_admins.new(community_admin_params)
    if @community_admin.save
      CommunityAdminPostService.new(@community_admin).call
      flash[:notice] = 'Community admin created successfully.'
      redirect_to step2_community_path(@community)
    else
      flash[:notice] = @community_admin.errors.full_messages.join(', ')
      render :step2_community_path, status: :unprocessable_entity
    end
  end

  def edit
    @community_admin = CommunityAdmin.find(params[:id])
  end

  def update
    @community_admin = CommunityAdmin.find(params[:id])
    if @community_admin.update(community_admin_params)
      CommunityAdminPostService.new(@community_admin).call
      flash[:notice] = 'Community admin updated successfully.'
      redirect_to step2_community_path(@community)
    else
      flash[:error] = @community_admin.errors.full_messages.join(', ')
      render :step2_community_path, status: :unprocessable_entity
    end
  end

  private

  def community_admin_params
    params.require(:community_admin).permit(:patchwork_community_id, :display_name, :username, :email, :password, :role)
  end

  def set_community!
    @community = Community.find(params[:community_admin][:community_id])
  end
end
