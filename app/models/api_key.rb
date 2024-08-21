class ApiKey < ApplicationRecord
  validates :key, :secret, :status
end
