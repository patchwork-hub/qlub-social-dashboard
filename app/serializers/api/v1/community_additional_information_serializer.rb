module Api
  module V1
    class CommunityAdditionalInformationSerializer
      include JSONAPI::Serializer
      attributes :id, :heading, :text, :created_at, :updated_at
    end
  end
end
