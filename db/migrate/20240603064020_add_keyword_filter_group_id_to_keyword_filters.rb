class AddKeywordFilterGroupIdToKeywordFilters < ActiveRecord::Migration[7.0]
  def change
    add_reference :keyword_filters, :keyword_filter_group, foreign_key: true
  end
end
