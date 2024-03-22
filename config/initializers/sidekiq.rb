require 'sidekiq'
require 'sidekiq/web'

redis_url = "redis://#{ENV["REDIS_HOST"]}:#{ENV['REDIS_PORT']}"

# "redis://localhost:6379/12"

Sidekiq.configure_server do |config|
  config.redis = {
    url: redis_url
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: redis_url
  }
end