class BlueskyBridgeEnabledJob < ApplicationJob
  queue_as :default

  def perform(value)
      User.update_all_bluesky_bridge_enabled(value)
  end
end
