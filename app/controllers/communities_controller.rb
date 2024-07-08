class CommunitiesController < ApplicationController
  before_action :set_community, only: %i[ show ]

  def index
    
  end

  def new
    respond_to do |format|
      format.html
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json {render json: @community, serializer: REST::CommunitySerializer }
    end
  end

  def create
    @community = CommunityService.new.call(@account, 
                                  name: @options[:name], 
                                  slug: @options[:slug],
                                  description: @options[:description],
                                  is_recommended: @options[:is_recommended],
                                  bio:  @options[:bio],
                                  guides: @options[:guides],
                                  patchwork_collection_id: @collection.id,
                                  position: @options[:position],
                                  admin_following_count: @options[:admin_following_count],
                                  image: @options[:image])
  end

  def community_params
    params.require(:community).permit(
      :name,
      :slug,
      :description,
      :collection_id,
      :position,
      :is_recommended,
      :bio,
      :image,
      guides:[:position,:title,:description])
  end

  private

  def set_community
    @community = Patchwork::Community::find_by(slug: params[:id])
    raise ActiveRecord::RecordNotFound unless @community
  end
end