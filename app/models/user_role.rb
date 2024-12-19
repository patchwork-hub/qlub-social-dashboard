
class UserRole < ApplicationRecord
  has_many :users, inverse_of: :role, foreign_key: 'role_id'

  FLAGS = {
    administrator: (1 << 0),
    invite_users: (1 << 16)
  }
end
