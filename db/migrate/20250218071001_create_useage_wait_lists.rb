class CreateUseageWaitLists < ActiveRecord::Migration[7.1]
  def change
    create_table :patchwork_useage_wait_lists do |t|
      t.references :account, null: false, foreign_key: {to_table: :accounts}
      t.references :wait_list, null: false, foreign_key: {to_table: :patchwork_wait_lists}
      t.timestamps
    end
    add_index :patchwork_useage_wait_lists, [:account_id, :wait_list_id], unique: true
  end
end
