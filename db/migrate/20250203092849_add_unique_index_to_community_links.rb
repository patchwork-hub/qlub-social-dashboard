class AddUniqueIndexToCommunityLinks < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!
  def change
    unless index_exists?(:patchwork_community_links, [:url, :patchwork_community_id], name: 'index_community_links_on_url_and_patchwork_id')
      add_index :patchwork_community_links, [:url, :patchwork_community_id], unique: true, name: 'index_community_links_on_url_and_patchwork_id', algorithm: :concurrently
    end
  end
end
