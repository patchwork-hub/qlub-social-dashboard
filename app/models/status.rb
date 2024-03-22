class Status < ApplicationRecord
  belongs_to :account, inverse_of: :statuses
  has_many :ban_statuses, inverse_of: :status

  has_and_belongs_to_many :tags
end