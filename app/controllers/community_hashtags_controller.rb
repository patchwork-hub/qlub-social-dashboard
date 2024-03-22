class CommunityHashtagsController < ApplicationController
  respond_to :html, :json
  
  before_action :set_community, only: %i[ new create ]
  load_and_authorize_resource

  def create
    @community_hashtag = CommunityHashtag.new(community_hashtag_params)
    @community_hashtag.name = community_hashtag_params[:hashtag].downcase
    if @community_hashtag.save
      redirect_to community_url(@community.slug, type: params[:type]), notice: 'A Hashtag was successfully created!'
    else
      flash[:error] = @community_hashtag.errors.full_messages
      render :new
    end
  end

  def update
    @community = @community_hashtag.community
    name = {name: community_hashtag_params[:hashtag].downcase}
    updated_params = community_hashtag_params.merge(name)
    if @community_hashtag.update(updated_params)
      redirect_to community_url(@community.slug, type: params[:type]), notice: 'A Hashtag was successfully updated!'
    else
      flash[:error] = @community_hashtag.errors.full_messages
      render :edit
    end
  end

  def destroy
    @community = @community_hashtag.community
    
    @community_hashtag.destroy

    redirect_to community_url(@community.slug, type: params[:type]), notice: 'A Hashtag was successfully destroyed!'
  end

  private

    def community_hashtag_params
      params.require(:community_hashtag).permit(:community_id, :hashtag, :is_incoming, :name)
    end

    def set_community
      @community = Community.find(params[:community_id].presence || community_hashtag_params[:community_id])
      raise ActiveRecord::RecordNotFound unless @community
    end
end