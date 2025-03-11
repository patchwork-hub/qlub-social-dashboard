class AddIsCustomDomainToCommunities < ActiveRecord::Migration[7.1]
  def change
    add_column :patchwork_communities, :is_custom_domain, :boolean, default: false, null: false
  end
end
