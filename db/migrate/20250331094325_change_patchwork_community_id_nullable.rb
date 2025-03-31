class ChangePatchworkCommunityIdNullable < ActiveRecord::Migration[7.1]
  def change
    change_column_null :patchwork_communities_admins, :patchwork_community_id, true
  end
end
