class GlobalFilter < ApplicationRecord
  self.table_name = 'mammoth_community_filter_keywords'

  belongs_to :account, inverse_of: :global_filters
  has_many :ban_statuses, inverse_of: :global_filter, foreign_key: :community_filter_keyword_id, dependent: :destroy

  validates :account_id, presence: true
  validates :keyword, presence: true
  # validate :validate_keyword_uniqueness

  after_update :dispatch_ban_status, if: :saved_change_to_keyword?
  after_create  -> { dispatch_ban_status('created') }

  protected

    def dispatch_ban_status(flag='updated')
      BanStatusJob.perform_later filter_id: self.id, flag: flag, is_hashtag: is_filter_hashtag
    end

    def validate_keyword_uniqueness
      if community_id.nil? && self.class.exists?(keyword: keyword, community_id: nil)
        errors.add(:keyword, "has already been taken")
      end
    end
end