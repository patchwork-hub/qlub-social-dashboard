module BlueskyAccountBridgeHleper

  def check_account_info(community)
    error_messages = []
    error_message = nil
    account = community&.community_admins&.first&.account
    
    if account&.username.blank?
      error_messages << "username"
    end

    if account&.display_name.blank?
      error_messages << "display name"
    end

    if account&.avatar.blank?
      error_messages << "avatar"
    end

    if account&.header.blank?
      error_messages << "header"
    end

    if error_messages.any?
      error_message = "Your account is missing #{error_messages.join(', ')}."
    end
    
    error_message
  end

  def bridged_completely?(community, bridge_info)
    return false if community.nil? || !bridge_info.present?
    domain = community.is_custom_domain? ? community.slug : "#{community.slug}.channel.org"
    bridge_info['did'] == community.did_value && bridge_info['handle'].eql?(domain)
  end

  def bridged_account_url(community, bridge_info)
    return false if community.nil? || !bridge_info.present?

    "https://bsky.app/profile/#{bridge_info['handle']}"
  end

  def bridged_handle(community, bridge_info)
    return false if community.nil? || !bridge_info.present?

    "@#{bridge_info['handle']}"
  end

end
