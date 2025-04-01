class AppVersionHistory < ApplicationRecord
  self.table_name = 'patchwork_app_version_histories'
  belongs_to :app_version, class_name: "AppVersion"
end
