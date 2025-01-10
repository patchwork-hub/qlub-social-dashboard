module Api
  module V1
    class ContentTypeSerializer
      include JSONAPI::Serializer
      attributes :id, :channel_type, :custom_condition, :patchwork_community_id, :created_at, :updated_at
    end
  end
end
