class KeywordFilter < ApplicationRecord
  self.table_name = 'keyword_filters'
  belongs_to :server_setting, class_name: "ServerSetting", optional: true
  validates :keyword, presence: true, uniqueness: true

  enum filter_type: { hashtag: 0, both: 1, content: 2 } 

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

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      keywords_hash = row.to_hash
      keyword = find_or_create_by!(keyword: keywords_hash['keyword'])
      keyword.is_active = keywords_hash['is_active']
      keyword.server_setting_id = ServerSetting.where(name:  keywords_hash['server_setting_id']).last.id
      keyword.filter_type = keywords_hash['filter_type']
      keyword.save!
   end
  end

end