class KeywordFilter < ApplicationRecord
  self.table_name = 'keyword_filters'
  belongs_to :server_setting, class_name: "ServerSetting", optional: true
end