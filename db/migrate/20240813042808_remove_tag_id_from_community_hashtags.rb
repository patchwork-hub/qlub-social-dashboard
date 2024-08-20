class RemoveTagIdFromCommunityHashtags < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_column :patchwork_communities_hashtags, :tag_id, :integer }
  end
end
