
# == Schema Information
#
# Table name: user_roles
#
#  id          :bigint           not null, primary key
#  color       :string           default(""), not null
#  highlighted :boolean          default(FALSE), not null
#  name        :string           default(""), not null
#  permissions :bigint           default(0), not null
#  position    :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class UserRole < ApplicationRecord
  has_many :users, inverse_of: :role, foreign_key: 'role_id'

  FLAGS = {
    administrator: (1 << 0),
    invite_users: (1 << 16)
  }
end
