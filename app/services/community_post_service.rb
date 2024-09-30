class CommunityPostService < BaseService
  def call(account, options = {})
    @account = account
    @options = options
    prepare_slug

    if @options[:id].present?
      update_community
    else
      create_community
    end

    @community
  rescue ActiveRecord::RecordNotUnique => e
    Rails.logger.error("Community creation/update failed: #{e.message}")
    @community.errors.add(:base, "An error occurred: #{e.message}")
    @community
  end

  def validate_unique_name
    existing_community = Community.find_by(name: @options[:name])
    if existing_community && existing_community.id != @options[:id].to_i
      @community ||= Community.new(community_attributes)
      @community.errors.add(:name, 'has already been taken')
      @community
    end
  end

  def create_community
    validate_collection
    validate_unique_name
    return @community if @community&.errors&.any?

    @community = @account.communities.new(community_attributes)
    @community.save!
    @community
  end

  def update_community
    @community = Community.find_or_initialize_by(id: @options[:id])
    validate_collection
    validate_unique_name
    return @community if @community&.errors&.any?

    update_community_attributes
    @community.save!
    @community
  end

  def validate_collection
    @collection = Collection.find_by(id: @options[:collection_id])
    raise ActiveRecord::RecordNotFound, "Collection not found" if @collection.nil?
  end

  def prepare_slug
    @slug = @options[:name].parameterize.underscore
  end

  def community_attributes
    {
      name: @options[:name],
      slug: @slug,
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

  def update_community_attributes
    @community.assign_attributes(community_attributes)
  end

  def get_position
    last_position = Community.order(:position).pluck(:position).last
    (last_position || 0) + 1
  end
end
