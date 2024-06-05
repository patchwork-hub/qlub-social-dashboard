class KeywordFilter < ApplicationRecord
  self.table_name = 'keyword_filters'
  validates :keyword, presence: true, uniqueness: true

  enum filter_type: { hashtag: 0, both: 1, content: 2 }

  def fetch_keyword_filter_api
    server_setting_id = ServerSetting.where(name: "Content filters").last&.id
    KeywordFilterApiService.new.get_keywords_filters.each do |keyword_filter|
      keywords = KeywordFilter.new(
        keyword: keyword_filter['keyword'],
        is_active: keyword_filter['is_active'],
        server_setting_id: server_setting_id,
        filter_type: keyword_filter['filter_type']
      )
      keywords.save
    end
  end

  def fetch_keywords_job

    content_filter = ServerSetting.find_by(name: "Content filters")

    return unless content_filter.present?

    KeywordFilter.destroy_all if KeywordFilter.exists?

    KeywordFilter.new.fetch_keyword_filter_api if content_filter.value
  end

end
