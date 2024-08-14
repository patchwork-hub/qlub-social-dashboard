class Follow < ApplicationRecord
  belongs_to :account
  belongs_to :target_account, class_name: 'Account'

  def self.ransackable_attributes(auth_object = nil)                                                            
    ["account_id",  "target_account_id"]                                                                                             
  end

  def self.ransackable_associations(auth_object = nil)                                                          
    ["account", "target_account"]                                                                               
  end
end