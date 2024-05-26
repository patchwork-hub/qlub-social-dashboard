module Scheduler
  class FetchContentKeywordScheduler
    include Sidekiq::Worker
    sidekiq_options retry: 0, queue: :scheduler

    def perform
      KeywordFilter.new.fetch_keywords_job
    end
  end
end