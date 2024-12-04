
class UserRole < ApplicationRecord
  has_many :users, inverse_of: :role, foreign_key: 'role_id'

  FLAGS = {
    manage_channel: 1 << 0,
    upload_logo: 1 << 1,
    administrator: 1 << 2
  }.freeze

  def permission?(permission)
    (permissions & FLAGS[permission.to_sym]) > 0
  end
end
