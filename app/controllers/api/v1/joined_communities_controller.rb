# frozen_string_literal: true

module Api
  module V1
    class JoinedCommunitiesController < ApiController
      skip_before_action :verify_key!
      before_action :check_authorization_header, only: [:index, :create, :destroy]
      before_action :login_with_mastodon, only: [:set_primary, :unset_primary]
      before_action :load_joined_channels, only: [:index, :set_primary, :unset_primary]

      def index
        sort_by_primary!

        render json: Api::V1::ChannelSerializer.new(
          @joined_communities,
          { params: { current_account: @account},
            meta: { total: @joined_communities.size }
          }
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
        
        unless is_newsmast?
          render json: { errors: 'You have no access to set primary' }, status: 422
        end

        unless @joined_communities&.any?
          return render json: { errors: 'You have no favourited channels' }, status: 422
        end
        
        unless @community
          return render json: { errors: 'Community not found' }, status: 404
        end

        @account.joined_communities.find_by(is_primary: true).update!(is_primary: false)

        ActiveRecord::Base.transaction do
          @account.joined_communities.where(is_primary: true).update_all(is_primary: false)
          joined_community = @account.joined_communities.find_by(patchwork_community_id: @community.id)
          joined_community.update!(is_primary: true)
        end
        render json: { message: 'Channel has been set as primary successfully' }, status: 200
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.message }, status: 422
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
          channel_type = is_newsmast? ? Community.channel_types[:newsmast] : Community.channel_types[:channel]

          Community.exclude_incomplete_channels.find_by(slug: slug).where(
            channel_type: channel_type
          )
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

        def load_joined_channels
          channel_type = is_newsmast? ? Community.channel_types[:newsmast] : Community.channel_types[:channel]
          @joined_communities = @account&.communities.where(deleted_at: nil).where(
            channel_type: channel_type
            )
          @community = Community.find_by(slug: params[:id])
        end

        def sort_by_primary!
          @joined_communities = @joined_communities&.to_a || []
          @joined_communities.sort_by! do |community|
            joined = community.joined_communities.find_by(account_id: @account.id)
            joined&.is_primary ? 0 : 1
          end
        end

        def is_newsmast?
          params[:platform_type].present? && params[:platform_type] == 'newsmast.social'
        end
    end
  end
end
