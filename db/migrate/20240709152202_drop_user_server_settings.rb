class DropUserServerSettings < ActiveRecord::Migration[7.0]
  def change
    drop_table :user_server_settings
  end
end
