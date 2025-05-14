# frozen_string_literal: true

module Api
  module V1
    class JoinedCommunitiesController < ApiController
      skip_before_action :verify_key!
      before_action :check_authorization_header, only: [:index, :create, :destroy]
      before_action :login_with_mastodon, only: [:set_primary, :unset_primary]
      before_action :joined_channels, only: [:index, :set_primary, :unset_primary]

      def index
        if @account.blank?
          render json: { errors: 'Account not found' }, status: 404
          return
        end

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

      def set_primary
        handle_primary_status_change(is_primary: true, error_message: 'Channel is already set primary')
      end

      def unset_primary
        handle_primary_status_change(is_primary: false, error_message: 'Channel is already unset primary')
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
          login_with_mastodon
        else
          authenticate_user_from_header
          @account = current_account
        end
      end

      def login_with_mastodon
        validate_mastodon_account
        @account = current_remote_account
      end

      def joined_channels
        @joined_communities = @account&.communities
        @community = Community.find_by(slug: params[:id])
      end

      def handle_primary_status_change(is_primary:, error_message:)
        unless @joined_communities&.any?
          return render json: { errors: 'You don\'t have favourited channels' }, status: 422
        end
      
        unless @community
          return render json: { errors: 'Community not found' }, status: 404
        end
      
        joined_channel = @account.joined_communities.find_by(patchwork_community_id: @community.id, is_primary: !is_primary)
        unless joined_channel
          return render json: { errors: error_message }, status: 422
        end
      
        if joined_channel.update(is_primary: is_primary)
          message = is_primary ? 'Channel has been set primary successfully' : 'Channel has been unset primary successfully'
          render json: { message: message }, status: 200
        else
          render json: { errors: joined_channel.errors.full_messages }, status: 422
        end
      end
    end
  end
end
