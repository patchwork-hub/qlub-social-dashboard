class AppVersion < ApplicationRecord
  self.table_name = 'mammoth_app_versions'

  has_many :app_version_histories, inverse_of: :app_version, dependent: :destroy

  validates :version_name, presence: true, uniqueness: true
end