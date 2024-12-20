class ValidateForeignKeyCommunityHashtags < ActiveRecord::Migration[7.1]
  def change
    validate_foreign_key :patchwork_communities_hashtags, :patchwork_communities
  end
end
