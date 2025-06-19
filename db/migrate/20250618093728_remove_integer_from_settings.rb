class RemoveIntegerFromSettings < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_column :patchwork_settings, :integer, :integer }
    change_column_default :patchwork_settings, :app_name, from: nil, to: 0
  end
end
