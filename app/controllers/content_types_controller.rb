class ContentTypesController < ApplicationController

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

  def content_type_params
    params.require(:content_type).permit(:channel_type, :custom_condition, :patchwork_community_id)
  end
end
