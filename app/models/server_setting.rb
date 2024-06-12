class ServerSetting < ApplicationRecord
  validates :name, presence: true

  has_many :user_server_settings
  has_many :users, through: :user_server_settings
  has_many :keyword_filter_groups, dependent: :destroy

  belongs_to :parent, class_name: "ServerSetting", optional: true
  has_many :children, class_name: "ServerSetting", foreign_key: "parent_id", dependent: :destroy

  after_update :invoke_keyword_schedule, if: :saved_change_to_value?, if: :content_filters?

  private
  def invoke_keyword_schedule
    return KeywordFiltersJob.perform_now
  end

  def content_filters?
    name == "Content filters"
  end
end
