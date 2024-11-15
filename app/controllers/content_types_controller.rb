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
    if @content_type.group_channel?
      community = Community.find_by(id: params[:content_type][:patchwork_community_id])

      if community
        account_name = "#{community.slug.underscore}_channel"
        account = Account.find_by(username: account_name)
        if account.update(locked: true)
          Rails.logger.info("Account #{account_name} locked successfully.")
        else
          Rails.logger.error("Failed to lock account: #{account.errors.full_messages.join(', ')}")
        end
      end
    end
  end

  def content_type_params
    params.require(:content_type).permit(:channel_type, :custom_condition, :patchwork_community_id)
  end
end
