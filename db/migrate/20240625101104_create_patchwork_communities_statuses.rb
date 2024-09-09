class CreatePatchworkCommunitiesStatuses < ActiveRecord::Migration[7.1]
  def change
    create_table :patchwork_communities_statuses do |t|
      t.references :status, null: false, foreign_key: true
      t.references :patchwork_community, null: false, foreign_key: true
      t.timestamps
    end

    add_index :patchwork_communities_statuses, [:status_id, :patchwork_community_id], unique: true, name: 'index_patchwork_communities_statuses_on_status_and_community'
  end
end
  