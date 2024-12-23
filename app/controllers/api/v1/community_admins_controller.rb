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
    end
  end
end
