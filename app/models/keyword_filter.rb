# == Schema Information
#
# Table name: keyword_filters
#
#  id                      :bigint           not null, primary key
#  filter_type             :integer
#  keyword                 :string
#  keyword_filter_group_id :bigint           not null
#
# Indexes
#
#  index_keyword_filters_on_keyword_filter_group_id  (keyword_filter_group_id)
#
# Foreign Keys
#
#  fk_rails_...  (keyword_filter_group_id => keyword_filter_groups.id) ON DELETE => cascade
#
class KeywordFilter < ApplicationRecord
  self.table_name = 'keyword_filters'
  validates :keyword, presence: true, uniqueness: true

  belongs_to :keyword_filter_group

  enum filter_type: { content: 0, hashtag: 1, both: 2 }

end
