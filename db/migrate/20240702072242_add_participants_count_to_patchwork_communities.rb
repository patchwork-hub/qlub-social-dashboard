class AddParticipantsCountToPatchworkCommunities < ActiveRecord::Migration[7.1]
    def change
        safety_assured { add_column :patchwork_communities, :participants_count, :integer, default: 0 }
    end
end
  