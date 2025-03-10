class AddRegistrationModeToCommunities < ActiveRecord::Migration[7.1]
  def change
    add_column :patchwork_communities, :registration_mode, :string, default: 'none'
  end
end
