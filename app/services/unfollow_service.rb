# frozen_string_literal: true

class UnfollowService < BaseService
  def call(account, target_account)
    @source_account = account
    @target_account = target_account
    direct_unfollow!
  end

  private

  def follow_attributes
    {
      target_account_id: @target_account.id,
      account_id: @source_account.id,
      show_reblogs: true,
      uri: nil,
      notify: false,
      languages: nil
    }.compact
  end

  def direct_unfollow!
    @follow = Follow.find_by(follow_attributes)
    @follow&.destroy
  end
end