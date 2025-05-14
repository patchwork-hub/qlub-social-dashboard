# frozen_string_literal: true

module Api
  module V1
    class JoinedCommunitiesController < ApiController
      skip_before_action :verify_key!
      before_action :check_authorization_header, only: [:index, :create, :destroy]

      def index
        if @account.blank?
          render json: { errors: 'Account not found' }, status: 404
          return
        end

        @joined_communities = @account&.communities
        render json: Api::V1::ChannelSerializer.new(
          @joined_communities,
          { params: { current_account: @account} }
        ).serializable_hash.to_json
      end

      def create
        patchwork_community = find_patchwork_community(params[:id])
        return render json: { errors: 'Channel not found' }, status: 404 unless patchwork_community

        if already_favorited?(patchwork_community)
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
        return render json: { errors: 'Channel not found' }, status: 404 unless patchwork_community
        
        @joined_community = JoinedCommunity.find_by(patchwork_community_id: patchwork_community.id, account_id: @account.id)
        if @joined_community
          @joined_community.destroy
          render json: { message: 'Favourited channel successfully deleted' }, status: 200
        else
          render json: { errors: 'Favourited channel not found' }, status: 404
        end
      end

      private

      def already_favorited?(patchwork_community)
        return false if params[:instance_domain].present?
      
        CommunityAdmin.exists?(
          patchwork_community_id: patchwork_community.id,
          account_id: @account.id
        )
      end

      def joined_community_params
        params.permit(:account_id).merge(account_id: @account.id)
      end

      def find_patchwork_community(slug)
        return unless slug.present?

        Community.exclude_incomplete_channels.find_by(slug: slug)
      end

      def check_authorization_header
        if request.headers['Authorization'].present? && params[:instance_domain].present?
          validate_mastodon_account
          @account = current_remote_account
        else
          authenticate_user_from_header
          @account = current_account
        end
      end
    end
  end
end