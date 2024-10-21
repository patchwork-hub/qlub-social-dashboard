require_relative "boot"

require "rails/all"

require 'csv'

require 'doorkeeper'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Dashboard
  class Application < Rails::Application
    config.app_generators.scaffold_controller :responders_controller

    config.load_defaults 7.0

    config.time_zone = "London"

    config.paperclip_defaults = {
      storage: :s3,
      s3_credentials: {
        bucket: ENV['S3_BUCKET'],
        access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
        s3_region: ENV['AWS_REGION']
      },
      url: ':s3_alias_url',
      s3_host_alias: ENV["S3_ALIAS_HOST"],
      path: 'patchwork/:class/:attachment/:id_partition/:style/:filename',
      s3_protocol: :https
    }

    # smtp settings
    config.action_mailer.smtp_settings = {
      address:                  ENV["SMTP_SERVER"],
      port:                     ENV["SMTP_PORT"],
      user_name:                ENV["SMTP_LOGIN"],
      password:                 ENV["SMTP_PASSWORD"],
      domain:                   ENV['SMTP_DOMAIN'],
      authentication:           "login",
      enable_starttls_auto:     true
    }

    # Sidekiq/redis job runner
    config.active_job.queue_adapter = :sidekiq
    config.active_job.queue_name_prefix = "dashboard_#{Rails.env}"
  end
end
