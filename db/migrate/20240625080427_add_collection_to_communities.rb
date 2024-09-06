class AddCollectionToCommunities < ActiveRecord::Migration[7.1]
  def change
    safety_assured { add_reference :patchwork_communities, :patchwork_collection, null: false, foreign_key: true }
  end
end
  