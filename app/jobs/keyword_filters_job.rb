class KeywordFiltersJob < ApplicationJob
  queue_as :default

  def perform
    KeywordFilter.new.fetch_keywords_job
  end
  
end