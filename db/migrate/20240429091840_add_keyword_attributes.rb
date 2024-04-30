class AddKeywordAttributes < ActiveRecord::Migration[7.0]
  def change
    add_column :keyword_filters, :is_custom_filter, :boolean, default: false
    add_column :keyword_filters, :is_active, :boolean, default: true
    add_reference :keyword_filters, :server_setting, null: true, foreign_key: { to_table: :server_settings, on_delete: :cascade }, index: true
  end

end
