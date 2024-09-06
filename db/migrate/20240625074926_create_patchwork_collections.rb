class CreatePatchworkCollections < ActiveRecord::Migration[7.1]
  def change
    create_table :patchwork_collections do |t|
      t.string :name, null: false
      t.string :slug, null: false, index: { unique: true }
      t.integer :sorting_index, null: false

      t.timestamps
    end
  end
end
  