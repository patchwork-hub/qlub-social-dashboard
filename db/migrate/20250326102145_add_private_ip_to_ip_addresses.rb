class AddPrivateIpToIpAddresses < ActiveRecord::Migration[7.1]
  def change
    add_column :ip_addresses, :private_ip, :string
  end
end
