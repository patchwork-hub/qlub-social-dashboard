require 'sidekiq'
require 'sidekiq/web'
require 'sidekiq-scheduler'
require 'uri'
 
redis_url = if ENV['REDIS_PASSWORD'].present?
  "redis://:#{ENV['REDIS_PASSWORD']}@#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}"
else
  "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}"
end
 
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