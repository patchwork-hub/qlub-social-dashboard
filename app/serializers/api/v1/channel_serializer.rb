# frozen_string_literal: true

class Api::V1::ChannelSerializer
  include JSONAPI::Serializer
  include Rails.application.routes.url_helpers

  set_type :channel

  attributes :id, :name, :slug, :description, :is_recommended, :admin_following_count,
             :patchwork_collection_id, :guides, :participants_count,
             :visibility, :position, :channel_type, :created_at, :no_of_admins, :channel_content_type

  attribute :community_type do |object|
    Api::V1::PatchworkCommunityTypeSerializer.new(object.patchwork_community_type).serializable_hash
  end

  attribute :banner_image_url do |object|
    object.slug.present? ? object.banner_image.url : "https://s3-eu-west-2.amazonaws.com/patchwork-prod/explore/science.jpg"
  end

  attribute :avatar_image_url do |object|
    object.slug.present? ? object.avatar_image.url : "https://s3-eu-west-2.amazonaws.com/patchwork-prod/explore/science.jpg"
  end

  attribute :domain_name do |object|
    object.slug.present? ? "#{object.slug}.channel.org" : "channel.org"
  end

  attribute :follower do |object|
    object&.community_admins&.last&.account&.follower_count
  end

  attribute :admin_following_count do |object|
    object&.community_admins&.last&.account&.following_ids&.count
  end

  attribute :no_of_admins do |object|
    object.community_admins.count
  end

  attribute :favourited do |object, params|
    params[:current_account] ? JoinedCommunity.exists?(patchwork_community_id: object.id, account_id: params[:current_account]['id']) : false
  end

  attribute :community_admin do |object|
    community_admin = object&.community_admins&.first
    community_admin ? {
      id: community_admin.id,
      account_id: community_admin&.account&.id,
      username: community_admin&.account&.username ? "@#{community_admin&.account&.username}@#{self.default_domain}" : "",
    } : {}
  end

  attribute :channel_content_type do |object|
    object&.content_type&.custom_channel? ? 'Curated' : ''
  end

  private

  def self.default_domain
    case ENV.fetch('RAILS_ENV', nil)
    when 'staging'
      'staging.patchwork.online'
    when 'production'
      'channel.org'
    else
      'localhost.3000'
    end
  end

end
