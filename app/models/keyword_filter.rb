class KeywordFilter < ApplicationRecord
  self.table_name = 'keyword_filters'
  validates :keyword, presence: true, uniqueness: true

  enum filter_type: { content: 0, hashtag: 1, both: 2 }

end
