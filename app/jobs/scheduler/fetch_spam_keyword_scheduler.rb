module Scheduler
  class FetchSpamKeywordScheduler
    include Sidekiq::Worker
    sidekiq_options retry: 0, queue: :scheduler

    def perform
      KeywordFiltersJob.perform_now('Spam filters')
    end
  end
end
