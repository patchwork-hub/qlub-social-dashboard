module Api
  module V1
    class CommunityLinksController < ApiController
      skip_before_action :verify_key!

      def general
        icons_data = CommunityLink::GENERAL_ICONS.map do |icon|
          {
            name: icon.to_s,
            title: icon.to_s.titleize,
            icon_path: ActionController::Base.helpers.image_path("icons/#{icon.to_s.dasherize}.svg")
          }
        end
        render json: icons_data
      end

      def social
        icons_data = CommunityLink::SOCIAL_ICONS.map do |icon|
          {
            name: icon.to_s,
            title: icon.to_s.titleize,
            icon_path: ActionController::Base.helpers.image_path("icons/#{icon.to_s.dasherize}.svg")
          }
        end
        render json: icons_data
      end
    end
  end
end
