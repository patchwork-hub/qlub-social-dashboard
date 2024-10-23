# frozen_string_literal: true

class Api::V1::RecommendedGroupChannelsSerializer
  include JSONAPI::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :name, :slug

  attribute :recommended_channels do |object|
    Api::V1::RecommendedChannelsSerializer.new(object.patchwork_communities.recommended).serializable_hash
  end

end
