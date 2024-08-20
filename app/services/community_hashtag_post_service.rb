# frozen_string_literal: true

class CommunityHashtagPostService < BaseService
  def call(account, options = {})
    @account = account
    @options = options
    prepare_params!
    community_create_hashtag!
  end

  def community_hashtag_attribute
    {
      hashtag: @hashtag,
      name: @name,
      patchwork_community_id: @community_id
    }.compact
  end

  def community_create_hashtag!
    CommunityHashtag.find_or_create_by(community_hashtag_attribute)
  end

  def prepare_params!
    @hashtag = @options[:hashtag].gsub('#', '').downcase
    @name = @options[:hashtag].gsub('#', '')
    @community_id = @options[:community_id]
  end
end