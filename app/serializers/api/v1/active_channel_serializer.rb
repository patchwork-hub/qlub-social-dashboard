# frozen_string_literal: true
 
class Api::V1::ActiveChannelSerializer
  include JSONAPI::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :name, :slug

  attribute :grouped_channels do |object|
    grouped_channels = object.patchwork_communities.where.not(visibility: nil).order(position: :asc).group_by(&:id)
    grouped_channels.map do |id, communities|
      {
        id: id,
        channels: communities.map { |community| serialize_channel(community) }
      }
    end
  end

  class << self
    private

      def serialize_channel(community)
        {
          id: community.id,
          name: community.name,
          slug: community.slug,
          description: community.description,
          is_recommended: community.is_recommended,
          admin_following_count: community.admin_following_count,
          account_id: community.account_id,
          patchwork_collection_id: community.patchwork_collection_id,
          guides: community.guides,
          participants_count: community.participants_count,
          visibility: community.visibility,
          domain_name: community.slug.present? ? "#{community.slug}.channel.org" : nil,
          status: community.visibility.present? ? 'Complete' : 'Incomplete',
          banner_image_url:    community.banner_image.url,
          avatar_image_url: community.avatar_image.url
        }
      end
  end
end