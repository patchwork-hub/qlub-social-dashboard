class AddForeignKeyToJoinedCommunities < ActiveRecord::Migration[7.1]
  def change
    %i[patchwork_communities accounts].each do |table|
      remove_foreign_key :patchwork_joined_communities, table, if_exists: true
      add_foreign_key :patchwork_joined_communities, table, on_delete: :cascade, validate: false
    end
  end
end
