class AddPostVisibilityToCommunities < ActiveRecord::Migration[7.1]
  def change
    add_column :patchwork_communities, :post_visibility, :integer, default: 2, null: false
  end
end
