# frozen_string_literal: true

module Api
  module V1
    class ChannelsController < ApiController

      def index

        @channels = Community.where.not(visibility: nil)
        render json: Api::V1::ChannelSerializer.new(@channels).serializable_hash.to_json
      end

    end
  end
end