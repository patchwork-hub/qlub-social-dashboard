class RemoveDdlValueToCommunities < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      remove_column :patchwork_communities, :ddl_value
      add_column :patchwork_communities, :did_value, :string, default: nil, null: true
    end
  end
end
