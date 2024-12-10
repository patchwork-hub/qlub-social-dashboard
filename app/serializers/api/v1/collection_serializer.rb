# frozen_string_literal: true

class Api::V1::CollectionSerializer
  include JSONAPI::Serializer
  include Rails.application.routes.url_helpers

  set_type :collection

  attributes :id,
              :name,
              :slug,
              :sorting_index

  attribute :community_count do |object|
    if object.slug == "all-collection"
      Community.all.size
    else
      object.patchwork_communities.size
    end
  end

  attribute :banner_image_url do |object|
    object.banner_image.url
  end

  attribute :avatar_image_url do |object|
    object.avatar_image.url
  end

  attribute :channels do |object, params|
    communities = params[:recommended] ? object.patchwork_communities.recommended : object.patchwork_communities.order('patchwork_communities.position ASC, patchwork_communities.name ASC')
    Api::V1::ChannelSerializer.new(communities).serializable_hash
  end

end
