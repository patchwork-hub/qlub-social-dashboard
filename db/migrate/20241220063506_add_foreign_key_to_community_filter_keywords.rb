class AddForeignKeyToCommunityFilterKeywords < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :patchwork_communities_filter_keywords, :patchwork_communities, if_exists: true
    add_foreign_key :patchwork_communities_filter_keywords, :patchwork_communities, on_delete: :cascade, validate: false
  end
end
