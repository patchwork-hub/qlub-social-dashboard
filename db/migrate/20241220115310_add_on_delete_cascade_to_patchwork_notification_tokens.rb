class AddOnDeleteCascadeToPatchworkNotificationTokens < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :patchwork_notification_tokens, :accounts, if_exists: true
    add_foreign_key :patchwork_notification_tokens, :accounts, on_delete: :cascade, validate: false
  end
end
