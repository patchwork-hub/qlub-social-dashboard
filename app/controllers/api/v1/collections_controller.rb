# frozen_string_literal: true

module Api
  module V1
    class CollectionsController < ApiController
      skip_before_action :verify_key!, only: [:index, :fetch_channels]
      before_action :fetch_channel_details, only: [:fetch_channels]

      def index
        @all_collections = Collection.order(sorting_index: :asc).to_a
        add_all_collection
        render json: Api::V1::CollectionSerializer.new(@all_collections, params: { recommended: false }).serializable_hash.to_json
      end

      def fetch_channels
        if @channels
          render json: Api::V1::ChannelSerializer.new(@channels).serializable_hash.to_json
        else
          render json: { data: [] }
        end
      end

      private

      def fetch_channel_details
        return nil unless params[:slug].present?
        if  params[:slug] === 'all-collection'
          @channels = Community.filter_channels.ordered_pos_name
        else
          @channels = Collection.find_by(slug: params[:slug])&.patchwork_communities&.filter_channels.ordered_pos_name
        end
        @channels
      end

      def add_all_collection
        @all_collections.unshift(Collection.new(
        id: (@all_collections.last&.id || 1) + 1,
        name: "All",
        slug: "all-collection",
        sorting_index: 0,
        created_at: nil,
        updated_at: nil
      ))
      end
    end
  end
end