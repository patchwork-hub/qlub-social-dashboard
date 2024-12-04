class ValidateAccountForeignKeyOnCommunitiesAdmins < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    validate_foreign_key :patchwork_communities_admins, :accounts
  end
end
