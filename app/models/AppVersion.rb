# == Schema Information
#
# Table name: patchwork_app_versions
#
#  id           :bigint           not null, primary key
#  version_name :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_patchwork_app_versions_on_version_name  (version_name) UNIQUE
#
class AppVersion < ApplicationRecord
  self.table_name = 'patchwork_app_versions'
  has_many :app_version_hostories, class_name: "AppVersionHistory", dependent: :destroy

  validates :version_name, presence: true, uniqueness: true
end
