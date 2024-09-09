class CreatePatchworkCommunities < ActiveRecord::Migration[7.1]
  def change
    create_table :patchwork_communities do |t|
      t.string :name, null: false
      t.string :slug, null: false, index: { unique: true }
      t.string :description
      t.boolean :is_recommended, null: false, default: false
      t.integer :admin_following_count, default: 0
      t.references :account, null: false, foreign_key: true
      t.references :patchwork_collection, null: false, foreign_key: true
      t.integer :position, default: 0
      t.jsonb :guides, default: {}
      t.integer :participants_count, default: 0
      t.integer :visibility, default: 0
      t.timestamps
    end

    add_index :patchwork_communities, :name, unique: true
  end
end
