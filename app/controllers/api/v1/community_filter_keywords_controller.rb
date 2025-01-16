class Api::V1::CommunityFilterKeywordsController < ApiController
  skip_before_action :verify_key!
  before_action :authenticate_user_from_header
  before_action :set_community
  before_action :set_community_filter_keyword, only: [:update, :destroy]

  def index
    filter_type = params[:filter_type]

    if filter_type.blank? || !['filter_in', 'filter_out'].include?(filter_type)
      render json: { error: 'Invalid or missing filter_type parameter. Must be "filter_in" or "filter_out".' }, status: :bad_request
      return
    end

    @filter_keywords = get_community_filter_keyword(filter_type)

    render json: {
      data: @filter_keywords,
      meta: {
        current_page: @filter_keywords.current_page,
        total_pages: @filter_keywords.total_pages,
        per_page: @filter_keywords.limit_value,
        total_count: @filter_keywords.total_count
      }
    }
  end

  def create
    @community_filter_keyword = @community.patchwork_community_filter_keywords.new(community_filter_keyword_params)
    if @community_filter_keyword.save
      render json: { message: 'Keyword filter was successfully created.', data: @community_filter_keyword }, status: :created
    else
      render json: { errors: @community_filter_keyword.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @community_filter_keyword.update(community_filter_keyword_params)
      render json: { message: 'Keyword filter was successfully updated.', data: @community_filter_keyword }
    else
      render json: { errors: @community_filter_keyword.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @community_filter_keyword.destroy
    render json: { message: 'Keyword filter was successfully deleted.' }, status: :ok
  end

  private

  PER_PAGE = 5

  def set_community_filter_keyword
    @community_filter_keyword = @community.patchwork_community_filter_keywords.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Keyword filter not found' }, status: :ok
  end

  def community_filter_keyword_params
    params.require(:community_filter_keyword).permit(:keyword, :is_filter_hashtag, :filter_type)
  end

  def set_community
    @community = Community.find(params[:community_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Community not found' }, status: :not_found
  end

  def get_community_filter_keyword(filter_type)
    @community.patchwork_community_filter_keywords.where(filter_type: filter_type).order(created_at: :desc).page(params[:page]).per(PER_PAGE)
  end
end
