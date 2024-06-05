class KeywordFiltersJob < ApplicationJob
  queue_as :default

  def perform
    KeywordFilterGroup.new.fetch_keywords_job
  end
  
end