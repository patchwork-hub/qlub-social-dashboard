class CreateRules < ActiveRecord::Migration[7.1]
  def change
    create_table :patchwork_rules do |t|
      t.text :description
      t.timestamps
    end
  end
end
