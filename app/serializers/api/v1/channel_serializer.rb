# frozen_string_literal: true

class Api::V1::ChannelSerializer
  include JSONAPI::Serializer

  attributes :id,
            :name,
            :slug,
            :description,
            :is_recommended,
            :admin_following_count,
            :account_id,
            :patchwork_collection_id,
            :guides,
            :participants_count,
            :visibility,
            :domain_name,
            :status,
            :banner_image_url,
            :avatar_image_url

  attribute :domain_name do |object|
    object.slug.present? ? "#{object.slug}.channel.org" : nil
  end

  attribute :status do |object|
     object.visibility.present? ? 'Complete' : 'Incomplete'
  end

  attribute :banner_image_url do |object|
    rails_blob_path(object.banner_image, only_path: true) if object.banner_image.attached?
  end

  attribute :avatar_image_url do |object|
    rails_blob_path(object.avatar_image, only_path: true) if object.avatar_image.attached?
  end
  
end