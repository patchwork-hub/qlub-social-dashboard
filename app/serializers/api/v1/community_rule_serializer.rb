module Api
  module V1
    class CommunityRuleSerializer
      include JSONAPI::Serializer
      attributes :id, :rule, :created_at, :updated_at
    end
  end
end
