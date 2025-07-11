class CommunityAdminsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_community!, only: %i[create update]
  before_action :set_community_admin, only: %i[edit update]

  def new
  end

  def create
    @community_admin = @community.community_admins.new(community_admin_params)
    authorize @community_admin, :create?

    if User.exists?(email: params[:community_admin][:email])
      flash[:error] = 'Email already exists.'
      return redirect_to_step2
    end

    if @community_admin.save
      CommunityAdminPostService.new(@community_admin, current_user, @community).call
      flash[:notice] = case @community.channel_type
                       when 'hub'
                         'Hub admin created successfully.'
                       when 'channel_feed'
                         'Channel admin created successfully.'
                       else
                         'Community admin created successfully.'
                       end
    else
      flash[:error] = @community_admin.errors.full_messages.join(', ')
    end

    redirect_to_step2
  end

  def edit
  end

  def update
    if @community_admin.update(community_admin_params)
      CommunityAdminPostService.new(@community_admin, current_user, @community).call
      flash[:notice] = 'Community admin updated successfully.'
    else
      flash[:error] = @community_admin.errors.full_messages.join(', ')
    end

    redirect_to_step2
  end

  private

  def community_admin_params
    params.require(:community_admin).permit(:patchwork_community_id, :display_name, :username, :email, :password, :is_boost_bot, :role)
  end

  def set_community!
    @community = Community.find_by(id: params.dig(:community_admin, :community_id))
  end

  def set_community_admin
    @community_admin = CommunityAdmin.find(params[:id])
  end

  def redirect_to_step2
    redirect_to step2_community_path(@community)
  end
end
