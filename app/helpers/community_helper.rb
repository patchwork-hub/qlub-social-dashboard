module CommunityHelper
  def domain(account)
    return nil unless account&.present?

    if account&.domain?
      account&.domain
    else
      default_domain
    end
  end

  def username(account)
    return nil unless account&.present?

    account&.username
  end

  def account_url(account)
    return nil unless account&.present?

    protocol = %w[production staging].include?(ENV.fetch('RAILS_ENV', nil)) ? 'https' : 'http'
    "#{protocol}://#{domain(account)}/@#{username(account)}@#{domain(account)}"
  end

  def get_channel_content_type(community)
    content_type = @initial_content_types.find { |content_type| content_type[:value] == community&.content_type&.channel_type }
    channel_content_type = content_type[:name] if content_type.present?
  end

  def continue_path_for_step2(community)
    if community&.content_type&.custom_channel?
      step3_community_path(id: community.id, channel_type: community.channel_type)
    else
      step6_community_path(id: community.id, channel_type: community.channel_type)
    end
  end

  def continue_button_class(records)
    records.size.zero? ? 'disabled' : ''
  end

  def previous_path_for_step3(community)
    if current_user.organisation_admin?
      step1_communities_path(id: community.id, channel_type: community.channel_type)
    else
      step2_community_path(channel_type: community.channel_type)
    end
  end

  def continue_path_for_step3(community, content_type)
    if content_type&.custom_channel?
      step4_community_path(id: community.id, channel_type: community.channel_type)
    else
      step6_community_path(id: community.id, channel_type: community.channel_type)
    end
  end

  def previous_path_for_step6(community, content_type)
    return step4_community_path(id: community.id, channel_type: community.channel_type) if content_type&.custom_channel?

    if organisation_admin?
      step1_communities_path(id: community.id, channel_type: community.channel_type, content_type: content_type&.channel_type)
    elsif master_admin?
      step2_community_path(id: community.id, channel_type: community.channel_type)
    else
      step4_community_path(id: community.id, channel_type: community.channel_type)
    end
  end

  private

  def default_domain
    case ENV.fetch('RAILS_ENV', nil)
    when 'staging'
      'staging.patchwork.online'
    when 'production'
      'channel.org'
    else
      'localhost.3000'
    end
  end
end
