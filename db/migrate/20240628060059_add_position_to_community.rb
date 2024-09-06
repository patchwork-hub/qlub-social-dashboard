class AddPositionToCommunity < ActiveRecord::Migration[7.1]
  def change
    safety_assured { add_column :patchwork_communities, :position, :integer, default: 0 }
  end
end
