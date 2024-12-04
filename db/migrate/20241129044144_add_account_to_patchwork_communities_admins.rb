class AddAccountToPatchworkCommunitiesAdmins < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_reference :patchwork_communities_admins, :account, null: true, index: { algorithm: :concurrently }
    add_foreign_key :patchwork_communities_admins, :accounts, on_delete: :cascade, validate: false
  end
end
