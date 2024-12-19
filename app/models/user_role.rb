
class UserRole < ApplicationRecord
  has_many :users, inverse_of: :role, foreign_key: 'role_id'
  
  FLAGS = {
    administrator: (1 << 0),
    manage_channel: (1 << 20),
    upload_logo: (1 << 21)
  }
end
