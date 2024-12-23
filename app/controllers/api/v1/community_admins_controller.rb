module Api
  module V1
    class CommunityAdminsController < ApiController
      skip_before_action :verify_key!
      before_action :authenticate_with_token!

      def boost_bot_accounts
       render json: boost_bot_accounts_list
      end

      private

      def authenticate_with_token!
        provided_token = request.headers['Authorization']&.split(' ')&.last
        static_token = ENV['STATIC_TOKEN']

        unless provided_token == static_token
          render json: { error: 'Unauthorized: Invalid or missing API token.' }, status: :unauthorized
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
    end
  end
end
