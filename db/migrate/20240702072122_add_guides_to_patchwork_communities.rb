class AddGuidesToPatchworkCommunities < ActiveRecord::Migration[7.1]
    def change
        safety_assured { add_column :patchwork_communities, :guides, :jsonb, default: {} }
    end
end
  