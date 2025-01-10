class AddDdlValueToCommunities < ActiveRecord::Migration[7.1]
  def change
    add_column :patchwork_communities, :ddl_value, :string, default: nil, null: true
  end
end
