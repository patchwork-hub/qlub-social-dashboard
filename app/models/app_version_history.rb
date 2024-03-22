class AppVersionHistory < ApplicationRecord
  self.table_name = 'mammoth_app_version_historys'

  belongs_to :app_version, inverse_of: :app_version_histories
end