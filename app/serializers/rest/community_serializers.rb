class REST::CommunitySerializer < ActiveModel::Serializer
    attributes :id, :name, :slug, :description, :is_recommended, :admin_following_count, :account_id, :created_at, :updated_at, :patchwork_collection_id, :position, :guides, :participants_count
end