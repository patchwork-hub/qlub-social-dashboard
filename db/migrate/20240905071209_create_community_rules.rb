class CreateCommunityRules < ActiveRecord::Migration[7.1]
  def change
    create_table :community_rules do |t|
      t.references :patchwork_community, null: false, foreign_key: true
      t.references :patchwork_rules, null: false, foreign_key: true
      t.timestamps
    end
  end
end
