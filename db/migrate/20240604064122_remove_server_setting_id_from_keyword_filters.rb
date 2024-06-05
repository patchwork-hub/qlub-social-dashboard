class RemoveServerSettingIdFromKeywordFilters < ActiveRecord::Migration[7.0]
  def change
    remove_reference :keyword_filters, :server_setting, foreign_key: true
  end
end
