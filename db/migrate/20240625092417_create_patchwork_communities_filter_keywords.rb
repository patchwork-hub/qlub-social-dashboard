class CreatePatchworkCommunitiesFilterKeywords < ActiveRecord::Migration[7.1]
  def change
    create_table :patchwork_communities_filter_keywords do |t|
      t.references :account, null: false, foreign_key: true
      t.references :patchwork_community, null: false, foreign_key: true
      t.string :keyword, null: false
      t.boolean :is_filter_hashtag, null: false, default: false
      t.timestamps
    end
  end
end