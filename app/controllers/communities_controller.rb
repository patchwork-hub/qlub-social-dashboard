class CommunitiesController < BaseController
  before_action :set_community, only: %i[ show ]

  def step1
    respond_to do |format|
      format.html
    end
  end

  def step1_save
    respond_to do |format|
      format.html
    end
  end

  def step2
    respond_to do |format|
      format.html
    end
  end

  def step2_save
    respond_to do |format|
      format.html
    end
  end

  def step3
    respond_to do |format|
      format.html
    end
  end

  def step3_save
    respond_to do |format|
      format.html
    end
  end

  def step4
    respond_to do |format|
      format.html
    end
  end

  def step4_save
    respond_to do |format|
      format.html
    end
  end

  def step5
    respond_to do |format|
      format.html
    end
  end

  def step5_save
    respond_to do |format|
      format.html
    end
  end

  def step6
    respond_to do |format|
      format.html
    end
  end

  def step6_save
    respond_to do |format|
      format.html
    end
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
    # @community = CommunityService.new.call(@account, 
    #                               name: @options[:name], 
    #                               slug: @options[:slug],
    #                               description: @options[:description],
    #                               is_recommended: @options[:is_recommended],
    #                               bio:  @options[:bio],
    #                               guides: @options[:guides],
    #                               patchwork_collection_id: @collection.id,
    #                               position: @options[:position],
    #                               admin_following_count: @options[:admin_following_count],
    #                               image: @options[:image])
  end

  def community_params
    # params.require(:community).permit(
    #   :name,
    #   :slug,
    #   :description,
    #   :collection_id,
    #   :position,
    #   :is_recommended,
    #   :bio,
    #   :image,
    #   guides:[:position,:title,:description])
  end

  private

  def records_filter
    @filter = Filter::Community.new(params)
  end

  def set_community
    @community = Patchwork::Community::find_by(slug: params[:id])
    raise ActiveRecord::RecordNotFound unless @community
  end
end