class CreatePatchworkCommunitiesHashtags < ActiveRecord::Migration[7.1]
  def change
    create_table :patchwork_communities_hashtags do |t|
      t.references :patchwork_community, null: false, foreign_key: true
      t.string :hashtag
      t.string :name
      t.timestamps
    end

    add_index :patchwork_communities_hashtags, [:patchwork_community_id, :hashtag], unique: true, name: 'index_patchwork_communities_hashtags_on_hashtag_and_community'
  end
end
