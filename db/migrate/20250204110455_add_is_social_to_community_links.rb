class AddIsSocialToCommunityLinks < ActiveRecord::Migration[7.1]
  def change
    add_column :patchwork_community_links, :is_social, :boolean, default: false
  end
end
