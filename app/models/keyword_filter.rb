class KeywordFilter < ApplicationRecord
  self.table_name = 'keyword_filters'
  belongs_to :server_setting, class_name: "ServerSetting", optional: true
  validates :keyword, presence: true, uniqueness: true

  enum filter_type: { hashtag: 0, both: 1, content: 2 } 

  def fetch_keyword_filter_api
    KeywordFilter.destroy_all if KeywordFilter.count > 0 && KeywordFilterApiService.new.get_keywords_filters.any?
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

  # Generate a CSV File of All Keywords Records
  def self.to_csv(fields = column_names, options={})
    CSV.generate(headers: true) do |csv|
      csv << fields
      all.each do |keyword|
        csv << fields.map do |field|
          if field == 'server_setting_id'
            keyword.server_setting.name
          else
            keyword.attributes[field]
          end
        end
      end
    end
  end

end