class AddIsPrimaryToPatchworkJoinedCommunities < ActiveRecord::Migration[7.1]
  def change
    add_column :patchwork_joined_communities, :is_primary, :boolean, default: false, null: false
  end
end
