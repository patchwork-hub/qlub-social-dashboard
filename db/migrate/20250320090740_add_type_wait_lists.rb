class AddTypeWaitLists < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def self.up
    safety_assured do
      change_table :patchwork_wait_lists do |t|
        t.integer :channel_type, null: false, default: 0
      end
    end
  end

  def self.down
    safety_assured do
      if column_exists?(:patchwork_wait_lists, :channel_type)
        remove_column :patchwork_wait_lists, :channel_type
      end
    end
  end
end