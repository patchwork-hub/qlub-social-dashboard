class AddUniqueIndexToPatchworkCommunitiesFilterKeywords < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :patchwork_communities_filter_keywords, [:keyword, :is_filter_hashtag], unique: true, name: "index_on_keyword_and_is_filter_hashtag", algorithm: :concurrently
  end
end
