class FetchContentKeywordScheduler
  include Sidekiq::Worker
  sidekiq_options retry: 0, queue: :scheduler
  def perform
    content_filter = ServerSetting.where(name: "Content filters").last
    if content_filter&.value
      KeywordFilter.new.fetch_keyword_filter_api
    end
  end
end