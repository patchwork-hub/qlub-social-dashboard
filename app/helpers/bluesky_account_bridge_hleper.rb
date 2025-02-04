module BlueskyAccountBridgeHleper
  def check_account_info(community, account)
    error_messages = []
    error_message = nil
    
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

    bridge_info['did'] == community.did_value && bridge_info['handle'].eql?("#{community.slug}.channel.org") 
  end

  def bridged_account_url(community, bridge_info)
    return false if community.nil? || !bridge_info.present?

    "https://bsky.app/profile/#{bridge_info['handle']}"
  end

  def bridged_handle(community, bridge_info)
    return false if community.nil? || !bridge_info.present?

    bridge_info['handle']
  end

end
