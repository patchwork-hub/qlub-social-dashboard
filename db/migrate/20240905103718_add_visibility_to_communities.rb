class AddVisibilityToCommunities < ActiveRecord::Migration[7.1]
  def change
    add_column :patchwork_communities, :visibility, :integer, default: 0
  end
end
