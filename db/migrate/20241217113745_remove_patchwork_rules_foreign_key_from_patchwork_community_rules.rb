class RemovePatchworkRulesForeignKeyFromPatchworkCommunityRules < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :patchwork_community_rules, :patchwork_rules
    safety_assured { remove_reference :patchwork_community_rules, :patchwork_rules, foreign_key: false }
  end
end
