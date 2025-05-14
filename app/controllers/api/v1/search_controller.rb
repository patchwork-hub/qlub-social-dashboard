module Api
  module V1
    class SearchController < ApiController
      skip_before_action :verify_key!
      before_action :check_authorization_header, only: [:search]

      def search
        query = build_query(params[:q])
        
        render json: {
          communities: serialize_communities(query),
          channel_feeds: serialize_channel_feeds(query),
          newsmast_channels: {data: search_newsmast_channels}
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
                      .exclude_deleted_channels
                      .where("lower(name) LIKE :q OR lower(slug) LIKE :q", q: query)

        Api::V1::ChannelSerializer.new(communities).serializable_hash
      end

      def serialize_channel_feeds(query)
        channel_feeds = Community
                        .filter_channel_feeds
                        .exclude_array_ids
                        .exclude_incomplete_channels
                        .exclude_deleted_channels
                        .where("lower(name) LIKE :q OR lower(slug) LIKE :q", q: query)

        Api::V1::ChannelSerializer.new(channel_feeds, { params: { current_account: current_account } }).serializable_hash
      end

      def check_authorization_header
        authenticate_user_from_header if request.headers['Authorization'].present?
      end

      def search_newsmast_channels
        query = params[:q].to_s.downcase.strip
        results = NEWSMAST_CHANNELS.select do |channel|
          name = channel.dig(:attributes, :name).to_s.downcase
          slug = channel.dig(:attributes, :slug).to_s.downcase
          name.include?(query.strip) || slug.include?(query.strip)
        end
        results
      end
    end
  end
end