module Api
  module V1
    class CommunityAdminSerializer
      include JSONAPI::Serializer
      attributes :id, :display_name, :username, :email, :is_boost_bot, :role, :created_at, :updated_at
    end
  end
end
