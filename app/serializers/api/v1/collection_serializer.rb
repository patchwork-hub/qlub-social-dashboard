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
    object.patchwork_communities.size
  end

  attribute :channels do |object, params|
    communities = params[:recommended] ? object.patchwork_communities.recommended : object.patchwork_communities
    Api::V1::ChannelSerializer.new(communities).serializable_hash
  end

end
