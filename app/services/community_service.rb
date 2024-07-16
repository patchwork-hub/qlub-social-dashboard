class CommunityService
  # def call(account, options = {})
  #   @account = account
  #   @options = options
  # end

  # def create_community
  #   process_community!
  #   @community
  # end

  # def update_community
  # end


  # def get_communities
  # end

  # def delete_communities
  # end

  # private 

  # def community_attributes
  #   { name: @options[:name],
  #     slug: @options[:slug],
  #     description: @options[:description],
  #     is_recommended: @options[:is_recommended],
  #     bio:  @options[:bio] || '',
  #     guides: @options[:guides] if @options[:guides].any?,
  #     patchwork_collection_id: @collection.id,
  #     position: @options[:position],
  #     admin_following_count: @options[:admin_following_count],
  #     guides: @options[:guides] || {},
  #     image: @options[:image]
  #   }.compact 
  # end

  # def process_community!
  #   @community = @account.communities.new(community_attributes)

  #   ApplicationRecord.transaction do
  #      @community.save!
  #   end
  # end
end