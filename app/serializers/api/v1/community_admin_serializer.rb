module Api
  module V1
    class CommunityAdminSerializer
      include JSONAPI::Serializer
      attributes :id, :display_name, :username, :email, :is_boost_bot, :created_at, :updated_at

      attribute :role do |object|
        object.role.titleize.gsub('Admin', 'admin')
      end
    end
  end
end
