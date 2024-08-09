# frozen_string_literal: true

class CommunityPostService < BaseService
  def call(account, options = {})
    @account = account
    @options = options
    validate_collection
    create_community
  end

  def validate_collection
    @collection = Collection.find(@options[:collection_id]);
  end

  def create_community
    process_community!
    @community
  end

  def get_position
    last_position = Community.order(:position).pluck(:position).last
    (last_position || 0) + 1
  end

  def get_id
    last_id = Community.order(:id).pluck(:id).last
    (last_id || 0) + 1
  end
  

  def community_attributes
    { id: get_id,
      name: @options[:username],
      slug: @options[:username].parameterize.underscore,
      description: @options[:bio],
      is_recommended: false,
      guides: nil,
      patchwork_collection_id: @collection.id,
      position: get_position,
      admin_following_count: 0,
      banner_image: @options[:banner_image],
      avatar_image: @options[:avatar_image],
      account_id: @account.id
    }.compact
  end

  def process_community!
    @community = @account.communities.new(community_attributes)
    @community.save!
  end
end