class RemoveIsPrimaryFromPatchworkJoinedCommunities < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_column :patchwork_joined_communities, :is_primary, :boolean }
  end
end