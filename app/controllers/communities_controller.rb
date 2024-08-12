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
    session[:form_data] = form_params

    redirect_to step2_communities_path
  end

  def step2
    @records = load_commu_admin_records
    @search = commu_admin_records_filter.build_search
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
      format.json { render json: @community, serializer: REST::CommunitySerializer }
    end
  end

  private

  def initialize_form
    @community_form = Form::Community.new(session[:form_data] || {})
  end

  def form_params
    params.require(:form_community).permit(:name, :username, :collection_id, :bio, :banner_image, :avatar_image)
  end

  def records_filter
    @filter = Filter::Community.new(params)
  end

  def load_commu_admin_records
    commu_admin_records_filter.get
  end

  def commu_admin_records_filter
    @filter = Filter::CommunityAdmin.new(params)
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
