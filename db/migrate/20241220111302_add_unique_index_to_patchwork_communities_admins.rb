class AddUniqueIndexToPatchworkCommunitiesAdmins < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!
  def change
    unless index_exists?(:patchwork_communities_admins, [:account_id, :patchwork_community_id], name: 'unique_community_admin_index')
      add_index :patchwork_communities_admins, [:account_id, :patchwork_community_id], unique: true, name: 'unique_community_admin_index', algorithm: :concurrently
    end
  end
end
