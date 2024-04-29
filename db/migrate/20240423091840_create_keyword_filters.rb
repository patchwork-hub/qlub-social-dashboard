class CreateKeywordFilters < ActiveRecord::Migration[7.0]
  def change
    create_table :keyword_filters do |t|
      t.string :keyword
      t.references :server_setting, null: true, foreign_key: { to_table: :server_settings, on_delete: :cascade }, index: true
      t.boolean :is_custom_filter, default: false
      t.boolean :is_active, default: true
      t.boolean :is_filter_hashtag, default: false
    end
  end

end
