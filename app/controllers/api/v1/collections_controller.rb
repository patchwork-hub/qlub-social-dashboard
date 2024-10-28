# frozen_string_literal: true

module Api
  module V1
    class CollectionsController < ApiController

      before_action :set_collection, only: [:show]

      def index

        @collections = Collection.order(sorting_index: :asc)
        render json: Api::V1::CollectionSerializer.new(@collections, { params: { recommended: false } }).serializable_hash.to_json

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
          @collection = Collection.find_by(slug: params[:id])
        end

    end
  end
end