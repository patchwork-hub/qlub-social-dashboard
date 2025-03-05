module Api
  module V1
    class SearchController < ApiController
      skip_before_action :verify_key!, only: [:index]
      before_action :check_authorization_header, only: [:index]

      def index
        query = build_query(params[:q])
        
        render json: {
          communities: serialize_communities(query),
          collections: serialize_collections(query),
          channel_feeds: serialize_channel_feeds(query)
        }
      end

      private

      def build_query(param)
        param.present? ? "%#{param.downcase}%" : nil
      end

      def serialize_communities(query)
        communities = Community
                      .filter_channels
                      .exclude_array_ids
                      .exclude_incomplete_channels
                      .where("lower(name) LIKE :q OR lower(slug) LIKE :q", q: query)

        Api::V1::ChannelSerializer.new(communities).serializable_hash
      end

      def serialize_collections(query)
        collections = Collection
                      .where("lower(name) LIKE :q OR lower(slug) LIKE :q", q: query)

        Api::V1::CollectionSerializer.new(collections, { params: { recommended: false } }).serializable_hash
      end

      def serialize_channel_feeds(query)
        channel_feeds = Community
                        .filter_channel_feeds
                        .exclude_array_ids
                        .exclude_incomplete_channels
                        .where("lower(name) LIKE :q OR lower(slug) LIKE :q", q: query)

        Api::V1::ChannelSerializer.new(channel_feeds, { params: { current_account: current_account } }).serializable_hash
      end

      def check_authorization_header
        authenticate_user_from_header if request.headers['Authorization'].present?
      end
    end
  end
end