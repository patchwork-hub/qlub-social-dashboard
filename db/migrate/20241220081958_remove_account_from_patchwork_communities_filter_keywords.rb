class RemoveAccountFromPatchworkCommunitiesFilterKeywords < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      remove_reference :patchwork_communities_filter_keywords, :account, foreign_key: true, index: true
    end
  end
end
