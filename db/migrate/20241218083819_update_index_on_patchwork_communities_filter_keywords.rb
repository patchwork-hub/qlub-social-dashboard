class UpdateIndexOnPatchworkCommunitiesFilterKeywords < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    remove_index :patchwork_communities_filter_keywords, name: "index_on_keyword_and_is_filter_hashtag", algorithm: :concurrently

    add_index :patchwork_communities_filter_keywords,
              [:keyword, :is_filter_hashtag, :patchwork_community_id],
              unique: true,
              name: "index_on_keyword_is_filter_hashtag_and_patchwork_community_id",
              algorithm: :concurrently
  end
end
