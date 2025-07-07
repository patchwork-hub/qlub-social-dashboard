module Api
  module V1
    class CommunitiesController < ApiController
      skip_before_action :verify_key!
      before_action :authenticate_user_from_header, except: %i[bridge_information]
      before_action :set_community, only: %i[show update set_visibility manage_additional_information]
      before_action :validate_patchwork_community_id, only: %i[contributor_list mute_contributor_list]
      before_action :set_content_and_channel_type, only: %i[index create update]
      include BlueskyAccountBridgeHleper
      PER_PAGE = 5

      def index
        communities = records_filter.get.where(channel_type: @channel_type)
        render json: Api::V1::ChannelSerializer.new(communities).serializable_hash.to_json
      end

      def create
        if CommunityAdmin.exists?(account_id: current_user.account_id)
          render json: { error: "You can only create one channel." }, status: :forbidden and return
        end

        community = CommunityPostService.new.call(
          current_user,
          community_params.merge(content_type: @content_type, channel_type: @channel_type)
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
          community_params.merge(id: @community.id, content_type: @content_type)
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
        CreateCommunityInstanceDataJob.perform_later(@community) if @community.hub? && ENV['ALLOW_CHANNELS_CREATION'] == 'true'
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
          @community.errors.add(:base, "Missing additional information")
          return render json: { errors: @community.formatted_error_messages }, status: :unprocessable_entity
        end

        if @community.update(additional_community_params)
          @community.update(registration_mode: params[:community][:registration_mode])
          render json: Api::V1::ChannelSerializer.new(@community, include: [:patchwork_community_additional_informations, :patchwork_community_links, :patchwork_community_rules]).serializable_hash.to_json
        else
          render json: { errors: @community.formatted_error_messages }, status: :unprocessable_entity
        end
      rescue ActionController::ParameterMissing => e
        render json: { error: e.message }, status: :bad_request
      end

      def fetch_ip_address
        ip_address = if @community&.ip_address_id.present?
                       IpAddress.find_by(id: @community.ip_address_id)
                     else
                       IpAddress.valid_ip
                     end

        if ip_address
          render json: { ip_address: ip_address.ip, id: ip_address.id }, status: :ok
        else
          render json: { error: "No valid IP available" }, status: :not_found
        end
      end

      def bridge_information
        community = Community.find_by(id: params[:id])
        if community.nil?
          render json: { error: 'Community not found' }, status: :not_found and return
        end
        bluesky_info = BlueskyService.new(@community).fetch_bluesky_account
        render json: {
          community: community,
          bluesky_info: bluesky_info,
        }
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
         :community_type_id,
         :is_recommended,
         :is_custom_domain,
         :ip_address_id
        ).to_h

        if default_community_type_id.present?
          params_hash[:community_type_id] = default_community_type_id
        end

        params_hash
      end

      def additional_community_params
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

      def set_content_and_channel_type
        if current_user.user_admin?
          @content_type = 'custom_channel'
          @channel_type = 'channel_feed'
        elsif current_user.hub_admin?
          @content_type = 'broadcast_channel'
          @channel_type = 'hub'
        elsif current_user.organisation_admin?
          @content_type = current_user.account.community_admin&.community&.content_type&.channel_type
          @channel_type = 'channel'
        end
      end

      def validate_patchwork_community_id
        @patchwork_community_id = params[:patchwork_community_id]
        if @patchwork_community_id.blank?
          render json: { error: 'patchwork_community_id is required' }, status: :bad_request
        end
      end

      def fetch_contributors(type)
        account_ids = CommunityAdmin.where(patchwork_community_id: @patchwork_community_id, account_status: 0).pluck(:account_id)

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
