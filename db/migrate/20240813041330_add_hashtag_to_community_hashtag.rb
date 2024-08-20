class AddHashtagToCommunityHashtag < ActiveRecord::Migration[7.1]
  def change
    add_column :patchwork_communities_hashtags, :hashtag, :string
    add_column :patchwork_communities_hashtags, :name, :string
  end
end
