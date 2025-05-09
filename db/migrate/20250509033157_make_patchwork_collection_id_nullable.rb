class MakePatchworkCollectionIdNullable < ActiveRecord::Migration[7.1]
  def change
    change_column_null :patchwork_communities, :patchwork_collection_id, true
  end
end
