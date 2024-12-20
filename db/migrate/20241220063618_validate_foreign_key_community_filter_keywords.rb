class ValidateForeignKeyCommunityFilterKeywords < ActiveRecord::Migration[7.1]
  def change
    validate_foreign_key :patchwork_communities_filter_keywords, :patchwork_communities
  end
end
