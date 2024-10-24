# frozen_string_literal: true

class Api::V1::PatchworkCommunityTypeSerializer
  include JSONAPI::Serializer

  set_type :community_type

  attributes :id, :name
end