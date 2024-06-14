module Scheduler
  class FetchContentKeywordScheduler
    include Sidekiq::Worker
    sidekiq_options retry: 0, queue: :scheduler

    def perform
      KeywordFiltersJob.perform_now
    end
  end
end
