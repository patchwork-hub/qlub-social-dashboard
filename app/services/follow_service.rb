# frozen_string_literal: true

class FollowService < BaseService
  def call(account, target_account)
    @source_account = account
    @target_account = target_account
    direct_follow!
  end

  def follow_attributes
    {
      target_account_id: @target_account.id,
      account_id: @source_account.id,
      show_reblogs: true,
      uri: nil,
      notify: true,
      languages: nil
    }.compact
  end

  def direct_follow!
    @follow = Follow.find_or_create_by(follow_attributes)
  end
end