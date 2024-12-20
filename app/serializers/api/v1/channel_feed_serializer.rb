class Api::V1::ChannelFeedSerializer
  include JSONAPI::Serializer

  set_type :channel_feed

  attributes :id,
            :username,
            :email,
            :display_name,
            :confirmed_at,
            :suspended_at,
            :domain_name,
            :avatar_image_url

  attribute :email do |object|
    object.user.email if object.user
  end

  attribute :confirmed_at do |object|
    object.user.confirmed_at if object.user
  end

  attribute :domain_name do |object|
    object.domain.presence || ENV['MASTODON_INSTANCE_URL']
  end

  attribute :avatar_image_url do |object|
    object.avatar_url
  end


  # Access community object using instance_options
  # attribute :avatar_image_url do |_object|
  #   community = @instance_options[:community]
  #   community.slug.present? ? community.avatar_image.url : "https://s3-eu-west-2.amazonaws.com/patchwork-prod/explore/science.jpg"
  # end
end
