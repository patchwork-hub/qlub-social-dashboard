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