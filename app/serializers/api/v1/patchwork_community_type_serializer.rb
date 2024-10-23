# frozen_string_literal: true

class Api::V1::PatchworkCommunityTypeSerializer
  include JSONAPI::Serializer

  attributes :id, :name
end