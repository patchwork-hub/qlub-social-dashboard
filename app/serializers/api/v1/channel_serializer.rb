# frozen_string_literal: true

class Api::V1::ChannelSerializer
  include JSONAPI::Serializer
  include Rails.application.routes.url_helpers

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
    image_url(object.banner_image)
  end

  attribute :avatar_image_url do |object|
    image_url(object.avatar_image)
  end

  private

  def self.image_url(image)
    image.attached? ? Rails.application.routes.url_helpers.rails_blob_url(image, only_path: true) : nil
  end
end