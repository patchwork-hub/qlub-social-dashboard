class CommunityFilterKeywordsController < ApplicationController
  before_action :set_community_filter_keyword, only: [:edit, :update, :destroy]

  def create
    @community_filter_keyword = CommunityFilterKeyword.new(community_filter_keyword_params)

    if @community_filter_keyword.save
      redirect_to step4_communities_path, notice: 'Keyword filter was successfully created.'
    else
      flash[:error] = 'Error creating keyword filter. Please check your input.'
      redirect_to step4_communities_path
    end
  end

  def update
    if @community_filter_keyword.update(community_filter_keyword_params)
      redirect_to step4_communities_path, notice: 'Keyword filter was successfully updated.'
    else
      flash[:error] = 'Error creating keyword filter. Please check your input.'
      redirect_to step4_communities_path
    end
  end

  def destroy
    @community_filter_keyword.destroy
    redirect_to step4_communities_path, notice: 'Keyword filter was successfully deleted.'
  end

  private

  def set_community_filter_keyword
    @community_filter_keyword = CommunityFilterKeyword.find(params[:id])
  end

  def community_filter_keyword_params
    params.require(:community_filter_keyword).permit(:account_id, :patchwork_community_id, :keyword, :is_filter_hashtag)
  end
end
