class CommunityAdminsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_community!, only: %i[create update]

  def new
  end

  def create
    @community_admin = @community.community_admins.new(community_admin_params)
    authorize @community_admin, :create?
    if @community_admin.save
      CommunityAdminPostService.new(@community_admin, current_user, @community).call
      # FollowBlueskyBotJob.perform_now(@community.id) if @community_admin.is_boost_bot
      flash[:notice] = 'Community admin created successfully.'
      redirect_to step2_community_path(@community)
    else
      flash[:error] = @community_admin.errors.full_messages.join(', ')
      redirect_to step2_community_path(@community)
    end
  end

  def edit
    @community_admin = CommunityAdmin.find(params[:id])
  end

  def update
    @community_admin = CommunityAdmin.find(params[:id])
    if @community_admin.update(community_admin_params)
      CommunityAdminPostService.new(@community_admin, current_user, @community).call
      flash[:notice] = 'Community admin updated successfully.'
      redirect_to step2_community_path(@community)
    else
      flash[:error] = @community_admin.errors.full_messages.join(', ')
      redirect_to step2_community_path(@community)
    end
  end

  private

  def community_admin_params
    params.require(:community_admin).permit(:patchwork_community_id, :display_name, :username, :email, :password, :is_boost_bot, :role)
  end

  def set_community!
    @community = Community.find(params[:community_admin][:community_id])
  end
end
