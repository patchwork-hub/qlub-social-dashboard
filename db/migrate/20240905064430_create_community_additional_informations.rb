class CreateCommunityAdditionalInformations < ActiveRecord::Migration[7.1]
  def change
    create_table :community_additional_informations do |t|
      t.string :heading
      t.text :text
      t.references :community, null: false, foreign_key: { to_table: :patchwork_communities, on_delete: :cascade }

      t.timestamps
    end
  end
end
