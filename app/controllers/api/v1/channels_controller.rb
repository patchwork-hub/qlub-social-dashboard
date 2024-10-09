# frozen_string_literal: true

module Api
  module V1
    class ChannelsController < ApiController

      def index

        @channels = Collection.joins(:patchwork_communities).where.not(patchwork_communities: { visibility: nil }).order(sorting_index: :asc)
        render json: Api::V1::ActiveChannelsSerializer.new(@channels).serializable_hash.to_json

      end

    end
  end
end