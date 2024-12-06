
class UserRole < ApplicationRecord
  has_many :users, inverse_of: :role, foreign_key: 'role_id'
end
