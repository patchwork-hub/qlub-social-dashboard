# frozen_string_literal: true

class WaitList < ApplicationRecord
  self.table_name = 'patchwork_wait_lists'
  has_one :useage_wait_list, class_name: 'UseageWaitList', foreign_key: 'wait_list_id'
  has_one :account, through: :useage_wait_list, class_name: 'Account', dependent: :destroy

  validates :invitation_code, presence: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :description, length: { maximum: 255 }, allow_blank: true

  def generate_invitation_code
    loop do
      self.invitation_code = SecureRandom.random_number(100_000..999_999).to_s
      break unless WaitList.exists?(invitation_code: self.invitation_code)
    end
  end
end
