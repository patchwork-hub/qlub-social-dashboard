class AddCommunityTypeToCommunity < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!
  
  def change
    add_reference :patchwork_communities, :patchwork_community_type, index: {algorithm: :concurrently}
  end
end
