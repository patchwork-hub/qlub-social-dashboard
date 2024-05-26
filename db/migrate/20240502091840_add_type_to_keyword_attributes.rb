class AddTypeToKeywordAttributes < ActiveRecord::Migration[7.0]
  def change
    remove_column :keyword_filters, :is_custom_filter
    remove_column :keyword_filters, :is_filter_hashtag
    add_column :keyword_filters, :filter_type, :integer
  end

end
