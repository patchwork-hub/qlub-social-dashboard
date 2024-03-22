class Report < ApplicationRecord
  belongs_to :reporter, class_name: 'Account', foreign_key: 'account_id'
  belongs_to :owner, class_name: 'Account', foreign_key: 'target_account_id'

  def statuses
    Status.where(id: status_ids)
  end

end