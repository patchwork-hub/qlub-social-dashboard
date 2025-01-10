module Api
  module V1
    class CommunityAdminsController < ApiController
      skip_before_action :verify_key!
      before_action :authenticate_with_token!, only: %i[boost_bot_accounts]
      before_action :authenticate_user_from_header, except: :boost_bot_accounts
      before_action :set_community, except: :boost_bot_accounts
      before_action :set_community_admin, only: %i[show update]

      def boost_bot_accounts
        render json: boost_bot_accounts_list
      end

      def index
        community_admins = records_filter.get.order(created_at: :desc)
        render json: Api::V1::CommunityAdminSerializer.new(community_admins).serializable_hash.to_json
      end

      def show
        render json: Api::V1::CommunityAdminSerializer.new(@community_admin).serializable_hash, status: :ok
      end

      def update
        if @community_admin.update(community_admin_update_params)
          CommunityAdminPostService.new(@community_admin, current_user, @community).call
          render json: Api::V1::CommunityAdminSerializer.new(@community_admin).serializable_hash, status: :ok
        else
          render json: { errors: @community_admin.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def authenticate_with_token!
        authenticate_or_request_with_http_token do |token, _options|
          static_token = ENV.fetch('STATIC_TOKEN', nil).to_s
          ActiveSupport::SecurityUtils.secure_compare(token, static_token)
        end
      end

      def boost_bot_accounts_list
        community_admins = CommunityAdmin.where(is_boost_bot: true)

        result = {}

        community_admins.each do |community_admin|
          community = Community.find_by(id: community_admin.patchwork_community_id)
          next unless community

          channel_type = community.channel_type
          name = community.slug

          url = community.channel? ? "https://#{name}.channel.org" : ""

          account_id = community_admin.account_id

          result[name] = {
            account_id: account_id,
            channel_type: channel_type,
            url: url
          }
        end

        result
      end

      def community_admin_update_params
        params.permit(:email)
      end

      def records_filter
        params[:q] = { patchwork_community_id_eq: @community.id }
        Filter::CommunityAdmin.new(params)
      end

      def set_community_admin
        @community_admin = CommunityAdmin.find_by(id: params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Community admin not found' }, status: :not_found
      end

      def set_community
        p "COMMUNITY_PARAMS: #{params[:community_id]}"
        @community = Community.find(params[:community_id])
      end
    end
  end
end
