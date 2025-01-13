class AddDevicesUrlToAccounts < ActiveRecord::Migration[7.1]
  def change
    unless column_exists?(:accounts, :devices_url)
      add_column :accounts, :devices_url, :string
    end
  end
end