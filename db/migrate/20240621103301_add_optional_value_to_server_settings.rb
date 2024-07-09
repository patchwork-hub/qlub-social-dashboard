class AddOptionalValueToServerSettings < ActiveRecord::Migration[7.0]
  def change
    add_column :server_settings, :optional_value, :string, default: nil
  end
end
