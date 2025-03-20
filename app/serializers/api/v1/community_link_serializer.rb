module Api
  module V1
    class CommunityLinkSerializer
      include JSONAPI::Serializer
      attributes :id, :icon, :name, :url, :is_social, :created_at, :updated_at
    end
  end
end
