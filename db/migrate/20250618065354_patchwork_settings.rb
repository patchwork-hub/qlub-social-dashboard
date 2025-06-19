class PatchworkSettings < ActiveRecord::Migration[7.1]
  def change
    create_table :patchwork_settings do |t|
      t.integer :app_name, :integer, default: 0, null: false
      t.references :account, null: false, foreign_key: { on_delete: :cascade, validate: false }
      t.jsonb :settings, default: {}
      t.timestamps
    end
  end
end
