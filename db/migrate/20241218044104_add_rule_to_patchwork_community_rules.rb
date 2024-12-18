class AddRuleToPatchworkCommunityRules < ActiveRecord::Migration[7.1]
  def change
    add_column :patchwork_community_rules, :rule, :string
  end
end
