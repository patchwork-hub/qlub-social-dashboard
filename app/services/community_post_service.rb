class CommunityPostService < BaseService
  def call(account, options = {})
    @account = account
    @options = options

    if @options[:id].present?
      update_community
    else
      create_community
    end

    @community
  rescue ActiveRecord::RecordNotUnique => e
    Rails.logger.error("Community creation/update failed: #{e.message}")
    @community
  end

  def validate_uniqueness(attribute)
    existing_community = Community.find_by(attribute => @options[attribute])
    if existing_community && existing_community.id != @options[:id].to_i
      @community ||= Community.new(community_attributes)
      @community.errors.add(attribute, "has already been taken")
      @community
    end
  end

  def create_community
    validate_collection
    validate_uniqueness(:name)
    validate_uniqueness(:slug)
    return @community if @community&.errors&.any?

    @community = @account.communities.new(community_attributes)
    @community.save!
    @community
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Community creation failed: #{e.message}")
    @community
  end

  def update_community
    @community = Community.find_by(id: @options[:id])
    validate_collection
    validate_uniqueness(:name)
    validate_uniqueness(:slug)
    return @community if @community&.errors&.any?

    @community.update!(community_attributes)
    @community
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Community update failed: #{e.message}")
    @community
  end

  def validate_collection
    @collection = Collection.find_by(id: @options[:collection_id])
    raise ActiveRecord::RecordNotFound, "Collection not found" if @collection.nil?
  end

  def community_attributes
    attributes = {
      description: @options[:bio],
      is_recommended: false,
      guides: nil,
      patchwork_collection_id: @collection.id,
      position: get_position,
      admin_following_count: 0,
      avatar_image: @options[:avatar_image],
      banner_image: @options[:banner_image],
      account_id: @account.id
    }

    if @options[:id].nil?
      attributes[:name] = @options[:name]
      attributes[:slug] = @options[:slug]
    end
    attributes.compact
  end

  def get_position
    last_position = Community.order(:position).pluck(:position).last
    (last_position || 0) + 1
  end
end
