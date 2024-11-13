class ModifyPatchworkCommunitiesAdmins < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_reference :patchwork_communities_admins, :account, foreign_key: true }

    add_column :patchwork_communities_admins, :display_name, :string
    add_column :patchwork_communities_admins, :email, :string
    add_column :patchwork_communities_admins, :username, :string
    add_column :patchwork_communities_admins, :password, :string
  end
end
