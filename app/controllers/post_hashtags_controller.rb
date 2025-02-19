# app/controllers/post_hashtags_controller.rb
class PostHashtagsController < ApplicationController
  before_action :set_community
  before_action :set_post_hashtag, only: [:update, :destroy]

  def create
    authorize @community, :step5_save?
    PostHashtagService.new.call(post_hashtag_params)
    redirect_to step5_community_path(@community)
  end

  def update
    authorize @community, :step5_update?
    UpdateHashtagService.new.call(params[:form_post_hashtag])
    redirect_to step5_community_path(@community)
  end

  def destroy
    authorize @community, :step5_delete?
    @post_hashtag.destroy
    redirect_to step5_community_path(@community)
  end

  private

  def set_community
    @community = Community.find(params[:community_id])
  end

  def set_post_hashtag
    @post_hashtag = PostHashtag.find(params[:id])
  end

  def post_hashtag_params
    params.require(:form_post_hashtag).permit(:community_id, :hashtag1, :hashtag2, :hashtag3)
  end
end
