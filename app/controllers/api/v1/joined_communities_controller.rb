# frozen_string_literal: true

module Api
  module V1
    class JoinedCommunitiesController < ApiController
      skip_before_action :verify_key!
      before_action :authenticate_user_from_header, only: [:index, :create, :destroy]

      def index
        @joined_communities = current_account&.communities
        render json: Api::V1::ChannelSerializer.new(@joined_communities).serializable_hash.to_json
      end

      def create
        patchwork_community = find_patchwork_community(params[:id])
        return unless patchwork_community

        if CommunityAdmin.exists?(patchwork_community_id: patchwork_community.id, account_id: current_account.id)
          render json: { errors: 'Channel is already favourited' }, status: 422
          return
        end

        @joined_community = JoinedCommunity.new(joined_community_params.merge(patchwork_community_id: patchwork_community.id))

        if @joined_community.save
          render json: { message: 'Channel has been favorited successfully'}, status: 200
        else
          render json: { errors: @joined_community.errors.full_messages }, status: 422
        end
      end

      def destroy
        patchwork_community = find_patchwork_community(params[:id])
        return unless patchwork_community
        
        @joined_community = JoinedCommunity.find_by(patchwork_community_id: patchwork_community.id, account_id: current_account.id)
        if @joined_community
          @joined_community.destroy
          render json: { message: 'Favourited channel successfully deleted' }, status: 200
        else
          render json: { error: 'Favourited channel not found' }, status: 404
        end
      end

      private

      def joined_community_params
        params.permit(:account_id).merge(account_id: current_account.id)
      end

      def find_patchwork_community(slug)
        patchwork_community = Community.where(slug: slug).exclude_incomplete_channels.first
        unless patchwork_community
          render json: { errors: 'Channel not found' }, status: 404
        end
        patchwork_community
      end
    end
  end
end