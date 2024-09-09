class KeywordFilter < ApplicationRecord
  self.table_name = 'keyword_filters'
  validates :keyword, presence: true, uniqueness: true

  enum filter_type: { "post content": 0, hashtags: 1, both: 2 }

end
