class CreateKeywordFilters < ActiveRecord::Migration[7.0]
  def change
    create_table :keyword_filters do |t|
      t.string :keyword
      t.boolean :is_filter_hashtag, default: false
    end
  end

end
