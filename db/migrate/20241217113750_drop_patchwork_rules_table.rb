class DropPatchworkRulesTable < ActiveRecord::Migration[7.1]
  def up
    drop_table :patchwork_rules
  end

  def down
    create_table :patchwork_rules do |t|
      t.string :description
      t.timestamps
    end
  end
end
