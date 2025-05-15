# frozen_string_literal: true

class Api::V1::PatchworkCommunityHashtagSerializer
  include JSONAPI::Serializer

  set_type :hashtag

  attributes :id, :hashtag, :name, :created_at, :updated_at

end