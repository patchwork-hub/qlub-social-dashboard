# frozen_string_literal: true

class CommunityHashtagPostService < BaseService
  class InvalidHashtagError < StandardError; end

  def call(options = {})
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
    hashtag = CommunityHashtag.find_or_initialize_by(community_hashtag_attribute)
    hashtag.save!
  end

  def prepare_params!
    validate_hashtag!(@options[:hashtag])

    @hashtag = @options[:hashtag].gsub('#', '')
    @name = @hashtag
    @community_id = @options[:community_id]
  end

  def validate_hashtag!(hashtag)
    if hashtag.include?(' ')
      raise InvalidHashtagError, 'Hashtag cannot contain spaces.'
    end
  end
end
