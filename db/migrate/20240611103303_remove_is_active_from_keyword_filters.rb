class RemoveIsActiveFromKeywordFilters < ActiveRecord::Migration[7.0]
  def change
    remove_column :keyword_filters, :is_active
  end
end
