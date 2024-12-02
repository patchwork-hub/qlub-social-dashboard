class AddRoleToCommunityAdmins < ActiveRecord::Migration[7.1]
  def change
    add_column :patchwork_communities_admins, :role, :string
  end
end
