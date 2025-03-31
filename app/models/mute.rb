# == Schema Information
#
# Table name: mutes
#
#  id                 :bigint           not null, primary key
#  expires_at         :datetime
#  hide_notifications :boolean          default(TRUE), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  account_id         :bigint           not null
#  target_account_id  :bigint           not null
#
# Indexes
#
#  index_mutes_on_account_id_and_target_account_id  (account_id,target_account_id) UNIQUE
#  index_mutes_on_target_account_id                 (target_account_id)
#
# Foreign Keys
#
#  fk_b8d8daf315  (account_id => accounts.id) ON DELETE => cascade
#  fk_eecff219ea  (target_account_id => accounts.id) ON DELETE => cascade
#
class Mute < ApplicationRecord
  belongs_to :account
  belongs_to :target_account, class_name: 'Account'
end
