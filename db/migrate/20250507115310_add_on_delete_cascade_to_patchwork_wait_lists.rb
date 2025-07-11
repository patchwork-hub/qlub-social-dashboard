class AddOnDeleteCascadeToPatchworkWaitLists < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :patchwork_wait_lists, :accounts, if_exists: true
    add_foreign_key :patchwork_wait_lists, :accounts, on_delete: :cascade, validate: false
  end
end
