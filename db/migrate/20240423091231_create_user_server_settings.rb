class CreateUserServerSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :user_server_settings do |t|
      t.jsonb :setting, null: true
      t.references :user, null: false, foreign_key: { to_table: :users, on_delete: :cascade }, index: true
      t.references :server_setting, null: false, foreign_key: { to_table: :server_settings, on_delete: :cascade }, index: true
    end
  end
end
