require 'sidekiq'
require 'sidekiq/web'
require 'sidekiq-scheduler'

# redis_url = if ENV['REDIS_PASSWORD'].present?
#   "redis://:#{ENV['REDIS_PASSWORD']}@#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}"
# else
#   "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}"
# end

if Rails.env.production?
  Sidekiq.configure_server do |config|
    config.redis = {
      url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}",
      password: ENV['REDIS_PASSWORD']
    }
  end

  Sidekiq.configure_client do |config|
    config.redis = {
      url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}",
      password: ENV['REDIS_PASSWORD']
    }
  end
end

if Rails.env.development?
  Sidekiq.configure_server do |config|
    config.redis = {
      url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}"
    }
  end

  Sidekiq.configure_client do |config|
    config.redis = {
      url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}"
    }
  end
end