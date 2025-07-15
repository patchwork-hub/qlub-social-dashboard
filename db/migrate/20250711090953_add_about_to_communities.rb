class AddAboutToCommunities < ActiveRecord::Migration[7.1]
  def change
    add_column :patchwork_communities, :about, :string
  end
end
