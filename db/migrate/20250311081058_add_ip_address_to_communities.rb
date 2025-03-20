class AddIpAddressToCommunities < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_reference :patchwork_communities, :ip_address, index: {algorithm: :concurrently}
  end
end
