# frozen_string_literal: true

module Api
  module V1
    class CollectionsController < ApiController
      skip_before_action :verify_key!
      before_action :fetch_channel_details, only: [:fetch_channels]

      NEWSMAST_CHANNELS_SORTING_ORDERS = ['Newsmast Channels', 'News','Global Issues', 'Government & Politics', 'Environment', 'Communities & Allies', 'Business & Work', 'Technology', 'Science', 'Humanities', 'Culture', 'Sport', 'Lifestyle', ]
     
      def index
        @all_collections = fetch_all_channels_by_type(type: 'channel')
        render_collections(@all_collections, type: 'channel')
      end

      def newsmast_collections
        patchwork_collection_ids = extract_patchwork_collection_ids
        @all_collections = fetch_collections_by_ids(patchwork_collection_ids)

        # Sort collections by NEWSMAST_CHANNELS_SORTING_ORDERS
        @all_collections = @all_collections.sort_by do |collection|
          NEWSMAST_CHANNELS_SORTING_ORDERS.index(collection.name) || Float::INFINITY
        end
        
        render_collections(@all_collections, type: 'newsmast')
      end

      def channel_feed_collections
        @all_collections = fetch_all_channels_by_type(type: 'channel_feed')
        render_collections(@all_collections, type: 'channel_feed')
      end

      def fetch_channels
        if @channels
          render json: serialized_channels(@channels,type: params[:type])
        else
          render json: { data: [] }
        end
      end

      private

      def fetch_all_channels_by_type(type:)
        collections = if type == 'channel'
          Collection.filter_channels.distinct.order(sorting_index: :asc).to_a
        else
          Collection.filter_channel_feeds.distinct.order(sorting_index: :asc).to_a
        end
        add_all_collection(collections, type: type)
      end

      def extract_patchwork_collection_ids
        NEWSMAST_CHANNELS.map do |channel|
          channel.dig(:attributes, :patchwork_collection_id)
        end.compact
      end

      def fetch_collections_by_ids(ids)
        collections = Collection.where(id: ids).order(sorting_index: :asc).to_a
        add_all_collection(collections, type: 'newsmast')
      end

      def render_collections(collections, type:)
        render json: Api::V1::CollectionSerializer.new(
          collections, params: { recommended: false, type: type }
        ).serializable_hash.to_json
      end

      def serialized_channels(channels, type:)
        if type == 'channel' || type == 'channel_feed'
          Api::V1::ChannelSerializer.new(channels).serializable_hash.to_json
        else
          channels
        end
      end

      def fetch_channel_details
        return unless params[:slug].present? && params[:type].present?

        @channels = if params[:type] == 'newsmast'
                      fetch_newsmast_channels
                    else
                      fetch_communities(type:  params[:type])
                    end
      end

      def fetch_newsmast_channels
        if params[:slug] == 'all-collection'
          NEWSMAST_CHANNELS.presence
        else
          collection_id = Collection.find_by(slug: params[:slug])&.id
          return nil unless collection_id

          NEWSMAST_CHANNELS.select do |channel|
            channel.dig(:attributes, :patchwork_collection_id) == collection_id
          end
        end
      end

      def fetch_communities(type:)
        base_communities = if params[:slug] == 'all-collection'
          Community.where(deleted_at: nil)
        else
          collection = Collection.find_by(slug: params[:slug])
          collection&.patchwork_communities&.where(deleted_at: nil)
        end
        return [] unless base_communities

        scope = type == 'channel' ? :filter_channels : :filter_channel_feeds

        base_communities
        .public_send(scope)
        .exclude_array_ids
        .exclude_incomplete_channels
        .ordered_pos_name
      end

      def add_all_collection(collections, type:)
        name = case type
                  when 'channel'
                    'Communities'
                  when 'channel_feed'
                    'Channels'
                  else
                    'Newsmast Channels'
                end
        collections.unshift(
          Collection.new(
            id: (collections.last&.id || 1) + 1,
            name: name,
            slug: "all-collection",
            sorting_index: 0,
            created_at: nil,
            updated_at: nil
          )
        )
        collections
      end
    end
  end
end