class AddAttributesWaitLists < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def self.up
    safety_assured do
      change_table :patchwork_wait_lists do |t|
        unless column_exists?(:patchwork_wait_lists, :account_id)
          t.references :account, null: true, foreign_key: { to_table: :accounts }
        end
        t.datetime :confirmed_at
      end

      unless index_exists?(:patchwork_wait_lists, :account_id)
        add_index :patchwork_wait_lists, :account_id, algorithm: :concurrently
      end
    end
  end

  def self.down
    safety_assured do
      if column_exists?(:patchwork_wait_lists, :account_id)
        remove_reference :patchwork_wait_lists, :account, foreign_key: true
      end
      if column_exists?(:patchwork_wait_lists, :confirmed_at)
        remove_column :patchwork_wait_lists, :confirmed_at
      end
    end
  end
end