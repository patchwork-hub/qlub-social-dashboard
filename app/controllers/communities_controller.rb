class CommunitiesController < BaseController
  before_action :set_community, only: %i[show]
  before_action :initialize_form, expect: %i[show]
  before_action :set_current_step, except: %i[show]

  def step1
    respond_to do |format|
      format.html
    end
  end

  def step1_save
    @community = CommunityPostService.new.call(@current_user.account,
                        username: form_params[:username],
                        bio: form_params[:bio],
                        collection_id: form_params[:collection_id],
                        banner_image: form_params[:banner_image],
                        avatar_image: form_params[:avatar_image])
    
    if @community.errors.any?
      @community_form = Form::Community.new(form_params)
      flash.now[:error] = @community.errors.full_messages.join(', ')
      render :step1
    else
      session[:form_data] = form_params
      session[:form_data]['id'] = @community.id
      session[:form_data]['banner_image_url'] = rails_blob_url(@community.banner_image, only_path: false) if @community.banner_image.attached?
      session[:form_data]['avatar_image_url'] = rails_blob_url(@community.avatar_image, only_path: false) if @community.avatar_image.attached?
      redirect_to step2_communities_path
    end
  end

  def step2
    @community = Community.find(session[:form_data]['id'])
    @records = load_commu_admin_records
    @new_admin_form = Form::CommunityAdmin.new
    # @search = commu_admin_records_filter.build_search

    respond_to do |format|
      format.html
    end
  end

  def step2_save
    @community_admin = CommunityAdminPostService.new.call(
      @current_user.account,
      community_id: new_admin_form_params[:community_id],
      display_name: new_admin_form_params[:display_name],
      username: new_admin_form_params[:username],
      email: new_admin_form_params[:email],
      password: new_admin_form_params[:password])

    redirect_to step2_communities_path
  end

  def contributors_table
    @community = Community.find(session[:form_data]['id'])
    @contributor_records = load_contributors_records
    @contributor_search = commu_contributors_filter.build_search

    respond_to do |format|
      format.html { render partial: 'communities/contributors_table', locals: { records: @contributor_records } }
    end
  end

  def step3
    @records = load_commu_hashtag_records
    @search = commu_hashtag_records_filter.build_search

    @community_hashtag_form = Form::CommunityHashtag.new
    @community = Community.find(session[:form_data]['id'])
    respond_to do |format|
      format.html
    end
  end

  def step3_save
    CommunityHashtagPostService.new.call(@current_user.account,
                hashtag:  community_hashtag_params[:hashtag],
                community_id: community_hashtag_params[:community_id])
    redirect_to step3_communities_path
  end

  def step4
    @filter_keywords = get_community_filter_keyword
    admin_id = get_community_admin_id
    @community_filter_keyword = CommunityFilterKeyword.new(
      patchwork_community_id: session[:form_data]['id'],
      account_id: admin_id
    )

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
    @form_post_hashtag = Form::PostHashtag.new
    @community = Community.find(session[:form_data]['id'])
    @records = load_post_hashtag_records
    @search = post_hashtag_records_filter.build_search
    respond_to do |format|
      format.html
    end
  end

  def step5_save
    PostHashtagService.new.call(@current_user.account, post_hashtag_params)
    @community = Community.find(session[:form_data]['id'])
    @records = load_post_hashtag_records
    @search = post_hashtag_records_filter.build_search
    redirect_to step5_communities_path
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
      format.json { render json: @community, serializer: REST::CommunitySerializer }
    end
  end

  def search_contributor
    query = params[:query]
    
    api_base_url = ENV['LOCAL_DOMAIN']
    token = Doorkeeper::AccessToken.find_by(resource_owner_id: 1).token
    response = HTTParty.get("#{api_base_url}/api/v2/search",
      query: {
        q: query,
        resolve: true,
        limit: 5
      },
      headers: {
        'Authorization' => "Bearer #{token}"
      }
    )
    render json: response.parsed_response
  end

  private

  def initialize_form
    session[:form_data] = nil if params[:new_community] == 'true'
    @community_form = Form::Community.new(session[:form_data] || {})
  end

  def post_hashtag_params
    params.require(:form_post_hashtag).permit(:hashtag1, :hashtag2, :hashtag3, :community_id)
  end

  def community_hashtag_params
    params.require(:form_community_hashtag).permit(:community_id, :hashtag)
  end

  def form_params
    params.require(:form_community).permit(:id, :name, :username, :collection_id, :bio, :banner_image, :avatar_image)
  end

  def new_admin_form_params
    params.require(:form_community_admin).permit(:community_id, :display_name, :username, :email, :password)
  end

  def records_filter
    @filter = Filter::Community.new(params)
  end

  def load_commu_admin_records
    commu_admin_records_filter.get
  end

  def load_commu_hashtag_records
    commu_hashtag_records_filter.get
  end

  def load_contributors_records
    commu_contributors_filter.get
  end

  def load_post_hashtag_records
    post_hashtag_records_filter.get
  end

  def commu_contributors_filter
    params[:q] = { account_id_eq: @current_user.account.id }
    @contributor_filter = Filter::Follow.new(params)
  end

  def commu_admin_records_filter
    params[:q] = { patchwork_community_id_eq: @community.id }
    @filter = Filter::CommunityAdmin.new(params)
  end

  def post_hashtag_records_filter
    params[:q] = { patchwork_community_id_eq: @community.id }
    @filter = Filter::PostHashtag.new(params)
  end

  def commu_hashtag_records_filter
    @filter = Filter::CommunityHashtag.new(params)
  end

  def get_community_filter_keyword
    CommunityFilterKeyword.where(patchwork_community_id: session[:form_data]['id'])
  end

  def get_community_admin_id
    CommunityAdmin.where(patchwork_community_id: session[:form_data]['id']).last.account_id
  end

  def set_community
    @community = Patchwork::Community.find_by(slug: params[:id])
    raise ActiveRecord::RecordNotFound unless @community
  end

  def set_current_step
    case action_name
    when 'step1', 'step1_save'
      @current_step = 1
    when 'step2', 'step2_save'
      @current_step = 2
    when 'step3', 'step3_save'
      @current_step = 3
    when 'step4', 'step4_save'
      @current_step = 4
    when 'step5', 'step5_save'
      @current_step = 5
    when 'step6', 'step6_save'
      @current_step = 6
    else
      @current_step = 1
    end
  end
end
