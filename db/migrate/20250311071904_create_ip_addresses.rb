class CreateIpAddresses < ActiveRecord::Migration[7.1]
  def change
    create_table :ip_addresses do |t|
      t.string :ip, null: false
      t.integer :use_count, default: 0, null: false
      t.datetime :reserved_at

      t.timestamps
    end

    add_index :ip_addresses, :ip, unique: true
  end
end
