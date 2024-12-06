class AddChannelTypeToCommunities < ActiveRecord::Migration[7.1]
  def change
    add_column :patchwork_communities, :channel_type, :string, default: 'channel', null: false
  end
end
