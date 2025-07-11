class AddForeignKeyToCommunityRules < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :patchwork_community_rules, :patchwork_communities, if_exists: true
    add_foreign_key :patchwork_community_rules, :patchwork_communities, on_delete: :cascade, validate: false
  end
end
