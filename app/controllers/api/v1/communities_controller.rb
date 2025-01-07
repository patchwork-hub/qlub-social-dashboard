module Api
  module V1
    class CommunitiesController < ApiController
      skip_before_action :verify_key!
      before_action :authenticate_user_from_header
      before_action :set_community, only: %i[show update]
      before_action :authorize_community

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
        render json: Api::V1::ChannelSerializer.new(@community).serializable_hash.to_json
      end

      def update
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

      def authorize_community
        authorize @community, policy_class: CommunityPolicy if @community.present?
      end
    end
  end
end
