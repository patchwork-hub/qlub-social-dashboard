class CreateAppVersions < ActiveRecord::Migration[7.1]
  def change
    create_table :patchwork_app_versions do |t|
      t.string :version_name
      t.timestamps
    end

    add_index :patchwork_app_versions, :version_name, unique: true
  end
end