class AppVersion < ApplicationRecord
  self.table_name = 'patchwork_app_versions'
  has_many :app_version_hostories, class_name: "AppVersionHistory", dependent: :destroy

end
