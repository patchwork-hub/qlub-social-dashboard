module Api
  module V1
    class CommunitiesController < ApiController
      skip_before_action :verify_key!
      before_action :authenticate_user_from_header
      before_action :set_community, only: %i[show update set_visibility]
      before_action :validate_patchwork_community_id, only: %i[contributor_list mute_contributor_list]
      PER_PAGE = 5
      ACCESS_TOKEN_SCOPES = "read write follow push".freeze

      def index
        communities = records_filter.get.where(channel_type: 'channel_feed')
        render json: Api::V1::ChannelSerializer.new(communities).serializable_hash.to_json
      end

      def create
        if CommunityAdmin.exists?(account_id: current_user.account_id)
          render json: { error: "You can only create one channel." }, status: :forbidden and return
        end

        community = CommunityPostService.new.call(
          current_user,
          community_params.merge(content_type: 'custom_channel')
        )

        if community.errors.any?
          render json: { errors: community.errors.full_messages }, status: :unprocessable_entity
        else
          render json: { community: community }, status: :created
        end
      end

      def show
        authorize @community, :show?
        render json: Api::V1::ChannelSerializer.new(@community, include: [:patchwork_community_additional_informations, :patchwork_community_links, :patchwork_community_rules]).serializable_hash.to_json
      end

      def update
        authorize @community, :update?
        @community = CommunityPostService.new.call(
          current_user,
          community_params.merge(id: @community.id, content_type: 'custom_channel')
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
        url = ENV.fetch('MASTODON_INSTANCE_URL')
        token = bearer_token

        if query.blank? || url.blank? || token.blank?
          render json: { error: 'query, url and token parameters are required' }, status: :bad_request
          return
        end

        result = ContributorSearchService.new(query, url: url, token: token, account_id: current_user.account_id).call

        if result.any?
          render json: { 'accounts' => result }
        else
           render json: { message: 'No saved accounts found', 'accounts' => [] }, status: :ok
        end
      end

      def contributor_list
        contributors = fetch_contributors(:followed)
        render_contributors(contributors)
      end

      def mute_contributor_list
        contributors = fetch_contributors(:muted)
        render_contributors(contributors)
      end

      def set_visibility
        authorize @community, :set_visibility?
        if @community.visibility.nil?
          @community.update(visibility: 'public_access')
          render json: { message: "Channel created successfully" }, status: :ok
        else
          render json: { message: "Channel updated successfully" }, status: :ok
        end
      end

      def manage_additional_information
        authorize @community, :manage_additional_information?
        if params[:community].blank?
          render json: { error: "Missing additional information" }, status: :bad_request
          return
        end

        if @community.update(additional_information_params)
          @community.update(registration_mode: params[:registration_mode])
          render json: { message: "Additional information updated successfully" }, status: :ok
        else
          render json: { error: @community.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def community_params
        default_community_type_id = CommunityType.first&.id

        params_hash = params.permit(
         :name,
         :slug,
         :bio,
         :collection_id,
         :banner_image,
         :avatar_image,
         :community_type_id
        ).to_h

        if default_community_type_id.present?
          params_hash[:community_type_id] = default_community_type_id
        end

        params_hash
      end

      def additional_information_params
        params.require(:community).permit(
          patchwork_community_additional_informations_attributes: [:id, :heading, :text, :_destroy],
          social_links_attributes: [:id, :icon, :name, :url, :_destroy],
          general_links_attributes: [:id, :icon, :name, :url, :_destroy],
          patchwork_community_rules_attributes: [:id, :rule, :_destroy],
          registration_mode: []
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

      def validate_patchwork_community_id
        @patchwork_community_id = params[:patchwork_community_id]
        if @patchwork_community_id.blank?
          render json: { error: 'patchwork_community_id is required' }, status: :bad_request
        end
      end

      def fetch_contributors(type)
        account_ids = CommunityAdmin.where(patchwork_community_id: @patchwork_community_id).pluck(:account_id)

        account_ids =
          case type
          when :followed
            accounts = Account.where(id: account_ids)
            accounts.map{ |account| account.following_ids }.flatten.uniq
          when :muted
            Mute.where(account_id: account_ids).pluck(:target_account_id)
          else
            []
          end

        Account.where(id: account_ids).where.not(username: "bsky.brid.gy").page(params[:page]).per(params[:per_page] || PER_PAGE)
      end

      def render_contributors(contributors)
        serialized_contributors = Api::V1::ContributorSerializer.new(
          contributors,
          { params: { account_id: current_user.account_id } }
        ).serializable_hash

        render json: {
          contributors: serialized_contributors[:data],
          meta: pagination_meta(contributors)
        }
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
