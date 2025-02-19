class RemoveUseageWaitLists < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    safety_assured { drop_table :patchwork_useage_wait_lists, if_exists: true }
  end
end