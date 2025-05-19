# Enables rack-mini-profiler in development mode
if Rails.env.development?
  require 'rack-mini-profiler'

  # Start the profiler
  ::Rack::MiniProfilerRails.initialize!(Rails.application)

  # Optional: Customize settings
  Rack::MiniProfiler.config.position = 'bottom' # display at bottom of page
end