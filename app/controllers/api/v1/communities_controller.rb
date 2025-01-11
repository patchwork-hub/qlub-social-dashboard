module Api
  module V1
    class CommunitiesController < ApiController
      skip_before_action :verify_key!
      before_action :authenticate_user_from_header
      before_action :set_community, only: %i[show update]
      PER_PAGE = 5
      ACCESS_TOKEN_SCOPES = "read write follow push".freeze

      def index
        communities = records_filter.get.where(channel_type: 'channel_feed')
        render json: Api::V1::ChannelSerializer.new(communities).serializable_hash.to_json
      end

      def create
        community = CommunityPostService.new.call(
          current_user,
          community_params
        )

        if community.errors.any?
          render json: { errors: community.errors.full_messages }, status: :unprocessable_entity
        else
          render json: { community: community }, status: :created
        end
      end

      def show
        # authorize @community, :show?
        render json: Api::V1::ChannelSerializer.new(@community).serializable_hash.to_json
      end

      def update
        # authorize @community, :update?
        @community = CommunityPostService.new.call(
          current_user,
          community_params.merge(id: @community.id)
        )

        if @community.errors.any?
          render json: { errors: @community.errors.full_messages }, status: :unprocessable_entity
        else
          render json: { community: @community }, status: :ok
        end
      end

      def community_types
        community_types = CommunityType.pluck(:id, :name).map { |id, name| { id: id, name: name } }
        render json: { community_types: community_types }, status: :ok
      end

      def collections
        collections = Collection.pluck(:id, :name).map { |id, name| { id: id, name: name } }
        render json: { collections: collections }, status: :ok
      end

      def search_contributor
        query = params[:query]
        url = params[:url]
        token = Doorkeeper::AccessToken.find_by(token: bearer_token)
        token.update(scopes: ACCESS_TOKEN_SCOPES) if token.present?

        if query.blank? || url.blank? || token.blank?
          render json: { error: 'query, url and token parameters are required' }, status: :bad_request
          return
        end

        result = ContributorSearchService.new(query, url: url, token: token).call

        if result.any?
          render json: { 'accounts' => result }
        else
           render json: { message: 'No saved accounts found', 'accounts' => [] }, status: :ok
        end
      end

      def contributor_list
       patchwork_community_id = params[:patchwork_community_id]

         if patchwork_community_id.blank?
            render json: { error: 'patchwork_community_id is required' }, status: :bad_request
           return
        end

        contributors = get_contributer_list(patchwork_community_id)
        render json: {
          contributors: contributors,
          meta: pagination_meta(contributors)
        }
      end

      private

      def community_params
        params.permit(
         :name,
         :slug,
         :bio,
         :collection_id,
         :banner_image,
         :avatar_image,
         :community_type_id
        )
      end

      def records_filter
        Filter::Community.new(params, current_user)
      end

      def set_community
        @community = Community.find(params[:id]) if params[:id].present?
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Community not found' }, status: :not_found
      end

      def get_contributer_list(patchwork_community_id)
        account_id = CommunityAdmin.where(patchwork_community_id: patchwork_community_id).pluck(:account_id)
        follow_ids = Follow.where(account_id: account_id).pluck(:target_account_id)
        follow_request_ids = FollowRequest.where(account_id: account_id).pluck(:target_account_id)
        total_follows_ids = (follow_ids + follow_request_ids).uniq

         Account.where(id: total_follows_ids).page(params[:page]).per(params[:per_page] || PER_PAGE)
      end

      def pagination_meta(object)
        {
          current_page: object.current_page,
          next_page: object.next_page,
          prev_page: object.prev_page,
          total_pages: object.total_pages,
          total_count: object.total_count
        }
      end
    end
  end
end
