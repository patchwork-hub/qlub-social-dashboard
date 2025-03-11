module BlueskyAccountBridgeHleper

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
