module Api
  module V1
    class SearchController < ApiController
      skip_before_action :verify_key!, only: [:index]
      before_action :check_authorization_header, only: [:index]

      def index
        query = params[:q].present? ? "%#{params[:q].downcase}%" : nil
        communities = Community
                      .filter_channels
                      .exclude_array_ids
                      .exclude_incomplete_channels
                      .where(
                        "lower(name) LIKE :q OR lower(slug) LIKE :q",
                        q: query
                      )
        collections = Collection
                      .where(
                        "lower(name) LIKE :q OR lower(slug) LIKE :q",
                        q: query
                      )
        render json: {
          communities: Api::V1::ChannelSerializer.new(communities).serializable_hash,
          collections: Api::V1::CollectionSerializer.new(collections, { params: { recommended: false } }).serializable_hash
        }
      end

      private

      def check_authorization_header
        if request.headers['Authorization'].present?
          authenticate_user_from_header
        end
      end

    end
  end
end