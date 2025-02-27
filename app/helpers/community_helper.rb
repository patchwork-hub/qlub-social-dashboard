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
