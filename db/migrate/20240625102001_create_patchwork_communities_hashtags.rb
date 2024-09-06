class CreatePatchworkCommunitiesHashtags < ActiveRecord::Migration[7.1]
  def change
    create_table :patchwork_communities_hashtags do |t|
      t.references :tag, null: false, foreign_key: true
      t.references :patchwork_community, null: false, foreign_key: true
      t.timestamps
    end
    add_index :patchwork_communities_hashtags, [:tag_id, :patchwork_community_id], unique: true, name: 'index_patchwork_communities_hashtags_on_hashtag_and_community'
  end
end
  