class RemoveAccountFromPatchworkCommunities < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      remove_reference :patchwork_communities, :account, foreign_key: true, index: true
    end
  end
end
