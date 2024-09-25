class ChangeDefaultVisibilityInPatchworkCommunities < ActiveRecord::Migration[7.1]
  def change
    change_column_default :patchwork_communities, :visibility, from: 0, to: nil
  end
end
