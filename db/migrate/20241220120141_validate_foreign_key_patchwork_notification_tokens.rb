class ValidateForeignKeyPatchworkNotificationTokens < ActiveRecord::Migration[7.1]
  def change
    validate_foreign_key :patchwork_notification_tokens, :accounts
  end
end
