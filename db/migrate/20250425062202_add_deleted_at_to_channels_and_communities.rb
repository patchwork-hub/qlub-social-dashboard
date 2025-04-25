class AddDeletedAtToChannelsAndCommunities < ActiveRecord::Migration[7.1]
  def change
    add_column :patchwork_communities, :deleted_at, :datetime
  end
end
