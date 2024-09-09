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

    @community_admin = CommunityAdmin.where(patchwork_community_id: session[:form_data]['id']).last.account_id

    @follower_records = load_contributors_records
    @follower_search = commu_contributors_filter.build_search
    
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
    @community = Community.find(session[:form_data]['id'])
    @filter_keywords = get_community_filter_keyword
    admin_id = get_community_admin_id
    @muted_accounts = get_muted_accounts
<<<<<<< HEAD
    @community_post_type = CommunityPostType.find_or_initialize_by(patchwork_community_id: @community.id)
=======
>>>>>>> mmh_dev
    @community_filter_keyword = CommunityFilterKeyword.new(
      patchwork_community_id: @community.id,
      account_id: admin_id
    )

    respond_to do |format|
      format.html
    end
  end

  def step4_save
    @community = Community.find(session[:form_data]['id'])
  
    @community_post_type = CommunityPostType.find_or_initialize_by(patchwork_community_id: @community.id)
    
    if @community_post_type.update(community_post_type_params)
      flash[:success] = "Community post type preferences saved successfully!"
      redirect_to step4_communities_path
    else
      flash[:error] = "Failed to save post type preferences."
      render :step4
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

  def step5_delete
    PostHashtag.find(params[:format].to_i).destroy
    @community = Community.find(session[:form_data]['id'])
    @records = load_post_hashtag_records
    @search = post_hashtag_records_filter.build_search
    redirect_to step5_communities_path
  end

  def step5_update
    UpdateHashtagService.new.call(@current_user.account, params[:form_post_hashtag])
    @community = Community.find(session[:form_data]['id'])
    @records = load_post_hashtag_records
    @search = post_hashtag_records_filter.build_search
    redirect_to step5_communities_path
  end

  def step5_save
    PostHashtagService.new.call(@current_user.account, post_hashtag_params)
    @community = Community.find(session[:form_data]['id'])
    @records = load_post_hashtag_records
    @search = post_hashtag_records_filter.build_search
    redirect_to step5_communities_path
  end

  def step6
    @community = Community.find(session[:form_data]['id'])
    @rule_from = Form::CommunityRule.new
    @rule_records = CommunityRule.where(patchwork_community_id: @community.id)
    @aditional_information = @community.patchwork_community_additional_informations
    @community_admin = Account.find_by_id(get_community_admin_id)
  end

  def step6_rule_create
    CommunityRuleService.new.call(@current_user.account, params[:form_community_rule])
    redirect_to step6_communities_path
  end

  def set_visibility
    @community = Community.find(session[:form_data]['id'])
    if @community.update(visibility: params[:community][:visibility])
      clear_form_data_id
      redirect_to communities_path
    else
      render :step6
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
    
    api_base_url = 'http://localhost:3001/'
    token = 'GDtc2wQoxu8r7LBdrK26UecQAnSLtSOh5YPD5YRlZRc'
    # api_base_url = ENV['LOCAL_DOMAIN']
    # token = Doorkeeper::AccessToken.find_by(resource_owner_id: 1).token
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

  def mute_contributor
    target_account_id = params[:account_id]
    admin_account_id = get_community_admin_id
    mute = params[:mute]
    
    if mute
      Mute.find_or_create_by!(account_id: admin_account_id, target_account_id: target_account_id, hide_notifications: true)
    else
      Mute.find_by(account_id: admin_account_id, target_account_id: target_account_id)&.destroy
    end
  
    render json: { success: true }
  end

<<<<<<< HEAD
  def unmute_contributor
=======
def unmute_contributor
>>>>>>> mmh_dev
    target_account_id = params[:account_id]
    admin_account_id = get_community_admin_id
    Mute.find_by(account_id: admin_account_id, target_account_id: target_account_id)&.destroy
  
    redirect_to step4_communities_path
  end

  def is_muted
    target_account_id = params[:account_id]
    admin_account_id = get_community_admin_id
    is_muted = Mute.exists?(account_id: admin_account_id, target_account_id: target_account_id)
  
    render json: { is_muted: is_muted }
  end  

  def manage_additional_information
    @community = Community.find(session[:form_data]['id'])
    if @community.update(community_params)
      flash[:success] = "Additional information added successfully!"
      redirect_to step6_communities_path
    else
      flash[:error] = "Something went wrong!"
<<<<<<< HEAD
      redirect_to step6_communities_path
=======
      step6 
    
      render :step6
>>>>>>> mmh_dev
    end
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

  def community_params
    params.require(:community).permit(
      patchwork_community_additional_informations_attributes: [:id, :heading, :text, :_destroy]
    )
  end

<<<<<<< HEAD
  def community_post_type_params
    params.require(:community_post_type).permit(:posts, :reposts, :replies)
  end

=======
>>>>>>> mmh_dev
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

  def load_commu_follower_records
    commu_follower_filter.get
  end

  def commu_follower_filter
    @follower_filter = Filter::Account.new(params)
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

  def get_muted_accounts
    admin_account_id = get_community_admin_id
    muted_account_ids = Mute.where(account_id: admin_account_id).pluck(:target_account_id)
    Account.where(id: muted_account_ids)
  end
  
  def set_community
    @community = Patchwork::Community.find_by(slug: params[:id])
    raise ActiveRecord::RecordNotFound unless @community
  end

  def clear_form_data_id
    session[:form_data] ||= {}
    session[:form_data]['id'] = nil
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
