module Scheduler
  class BlockBlueskyBotScheduler
    include Sidekiq::Worker
    include ApplicationHelper

    sidekiq_options retry: 0, lock: :until_executed, lock_ttl: 15.minutes.to_i, queue: :scheduler

    def perform
      return if ServerSetting.find_by(name: 'Enable bluesky bridge')&.value

      BlockBlueskyBotService.new.call
    end

  end
end