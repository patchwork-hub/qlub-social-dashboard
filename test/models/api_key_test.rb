# == Schema Information
#
# Table name: api_keys
#
#  id         :bigint           not null, primary key
#  key        :string
#  secret     :string
#  status     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

class ApiKeyTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
