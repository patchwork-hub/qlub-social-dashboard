class ContentTypesController < ApplicationController
  after_action :update_admin, only: [:create]

  def create
    @content_type = ContentType.find_or_initialize_by(patchwork_community_id: params[:content_type][:patchwork_community_id])
    @content_type.assign_attributes(content_type_params)

    if @content_type.save
      redirect_to step3_community_path(id: params[:content_type][:patchwork_community_id])
    else
      redirect_to step3_community_path(id: params[:content_type][:patchwork_community_id])
    end
  end

  private

  def update_admin
    community = Community.find_by(id: params[:content_type][:patchwork_community_id])

    if community
      account = Account.find_by(id: community&.community_admins&.where(is_boost_bot: true)&.first&.account_id)

      if @content_type.group_channel?
        account.update(locked: true)
      else
        account.update(locked: false)
      end
    end
  end

  def content_type_params
    params.require(:content_type).permit(:channel_type, :custom_condition, :patchwork_community_id)
  end
end
