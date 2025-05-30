class UpdateVersionNameIndexOnAppVersions < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!
  def change
    if index_exists?(:patchwork_app_versions, :version_name, unique: true)
      remove_index :patchwork_app_versions, :version_name
    end

    add_index :patchwork_app_versions, [:version_name, :app_name], unique: true, algorithm: :concurrently
  end
end
