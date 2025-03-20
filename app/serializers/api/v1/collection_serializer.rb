# frozen_string_literal: true

class Api::V1::CollectionSerializer
  include JSONAPI::Serializer
  include Rails.application.routes.url_helpers

  set_type :collection

  attributes :id,
              :name,
              :slug,
              :sorting_index

  attribute :community_count do |object, params|
    if params[:type] == 'newsmast'
      newsmast_community_count(object)
    else
      default_community_count(object)
    end
  end

  attribute :banner_image_url do |object|
    object.banner_image.url
  end

  attribute :avatar_image_url do |object|
    object.avatar_image.url
  end

  attribute :channels do |object, params|
    if params[:type] == 'newsmast'
      newsmast_channels(object)
    else
      default_channels(object, params)
    end
  end

  private

  def self.newsmast_community_count(object)
    if object.slug == "all-collection"
      NEWSMAST_CHANNELS.size
    else
      NEWSMAST_CHANNELS.select { |channel| channel[:attributes][:patchwork_collection_id] == object.id }.size
    end
  end

  def self.default_community_count(object)
    if object.slug == "all-collection"
      Community.filter_channels.exclude_array_ids.exclude_incomplete_channels.size
    else
      object.patchwork_communities.exclude_array_ids.filter_channels.exclude_incomplete_channels.size
    end
  end

  def self.newsmast_channels(object)
    if object.slug == "all-collection"
      { data: [] }
    else
      { data: NEWSMAST_CHANNELS.select { |channel| channel[:attributes][:patchwork_collection_id] == object.id } }
    end
  end

  def self.default_channels(object, params)
    communities = params[:recommended] ? 
      object.patchwork_communities.exclude_array_ids.exclude_incomplete_channels.recommended : 
      object.patchwork_communities.filter_channels.exclude_array_ids.exclude_incomplete_channels.ordered_pos_name

    Api::V1::ChannelSerializer.new(communities).serializable_hash
  end

end
