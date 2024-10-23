# frozen_string_literal: true

class Api::V1::RecommendedChannelsSerializer
  include JSONAPI::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :name, :slug, :description, :is_recommended, :admin_following_count,
             :account_id, :patchwork_collection_id, :guides, :participants_count,
             :visibility

  attribute :patchwork_community_type do |object|
    Api::V1::PatchworkCommunityTypeSerializer.new(object.patchwork_community_type).serializable_hash
  end
          
  attribute :banner_image_url do |object|
    object.banner_image.url
  end

  attribute :avatar_image_url do |object|
    object.avatar_image.url
  end

end
