class AddStatusToCommunityAdmins < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def self.up
    safety_assured do
      change_table :patchwork_communities_admins do |t|
        t.integer :account_status, null: false, default: 0
      end
    end
  end

  def self.down
    safety_assured do
      if column_exists?(:patchwork_communities_admins, :account_status)
        remove_column :patchwork_communities_admins, :account_status
      end
    end
  end
end