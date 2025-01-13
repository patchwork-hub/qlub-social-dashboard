module Api
  module V1
    class CommunityHashtagsController < ApiController
      skip_before_action :verify_key!
      before_action :authenticate_user_from_header
      before_action :set_community
      before_action :set_community_hashtag, only: %i[update destroy]

      def index
        @records = load_commu_hashtag_records
        render json: {
          data: @records,
          meta: {
            current_page: @records.current_page,
            total_pages: @records.total_pages,
            per_page: @records.limit_value,
            total_count: @records.total_count
          }
        }, status: :ok
      end

      def create
        begin
          hashtag = params.require(:community_hashtag).require(:hashtag).gsub('#', '')
          perform_hashtag_action(hashtag, @community.id, :follow)

          render json: { message: "Hashtag saved successfully!" }, status: :created
        rescue CommunityHashtagPostService::InvalidHashtagError => e
          render json: { error: e.message }, status: :unprocessable_entity
        rescue ActiveRecord::RecordNotUnique => e
          render json: { error: "Duplicate entry: Hashtag already exists." }, status: :conflict
        rescue ActionController::ParameterMissing => e
          render json: { error: e.message }, status: :bad_request
        end
      end

      def update
        begin
          hashtag = params.require(:community_hashtag).require(:hashtag).gsub('#', '')
          if hashtag.include?(' ')
            render json: { error: 'Hashtag cannot contain spaces.' }, status: :unprocessable_entity
          end
          return if performed?

          perform_hashtag_action(@community_hashtag.hashtag, @community.id, :unfollow)
          @community_hashtag.update!(hashtag: hashtag, name: hashtag)
          perform_hashtag_action(@community_hashtag.hashtag, @community.id, :follow)

          render json: { message: "Hashtag updated successfully!" }, status: :ok
        rescue CommunityHashtagPostService::InvalidHashtagError => e
          render json: { error: e.message }, status: :unprocessable_entity
        rescue ActiveRecord::RecordNotUnique => e
          render json: { error: "Duplicate entry: Hashtag already exists." }, status: :conflict
        rescue ActionController::ParameterMissing => e
          render json: { error: e.message }, status: :bad_request
        end
      end

      def destroy
        begin
          return if performed?
          perform_hashtag_action(@community_hashtag.hashtag, nil, :unfollow)
          @community_hashtag.destroy!
          render json: { message: "Hashtag removed successfully!" }, status: :ok
        rescue => e
          render json: { error: "Failed to remove hashtag." }, status: :internal_server_error
        end
      end

      private

      PER_PAGE = 5

      def set_community
        @community = Community.find(params[:community_id])
        @api_base_url = ENV.fetch('MASTODON_INSTANCE_URL')
        @token = bearer_token
      end

      def set_community_hashtag
        @community_hashtag = @community.patchwork_community_hashtags.find(params[:id])
      end

      def community_hashtag_params
        params.require(:community_hashtag).permit(:hashtag, :community_id)
      end

      def load_commu_hashtag_records
        @community.patchwork_community_hashtags.page(params[:page]).per(params[:per_page] || PER_PAGE)
      end

      def perform_hashtag_action(hashtag_name, community_id = nil, action)
        if action == :follow && community_id
          CommunityHashtagPostService.new.call(hashtag: hashtag_name, community_id: community_id)
        end

        hashtag = SearchHashtagService.new(@api_base_url, @token, hashtag_name).call
        return unless hashtag

        service_class = action == :follow ? FollowHashtagService : UnfollowHashtagService
        service_class.new(@api_base_url, @token, hashtag[:name]).call
      end
    end
  end
end
