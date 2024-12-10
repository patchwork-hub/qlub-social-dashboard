# frozen_string_literal: true

module Api
  module V1
    class CollectionsController < ApiController
      skip_before_action :verify_key!, only: [:index, :show]
      before_action :set_collection, only: [:show]

      def index

      @all_collections = Collection.order(sorting_index: :asc).to_a
      add_all_collection
      render json: Api::V1::CollectionSerializer.new(@all_collections, params: { recommended: false }).serializable_hash.to_json

      end

      def show

        if @collection&.patchwork_communities.present?
          render json: Api::V1::ChannelSerializer.new(@collection&.patchwork_communities).serializable_hash.to_json
        else
          render json: { data: [] }
        end

      end

      private

        def set_collection 
          @collection = Collection.find_by(id: params[:id])
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