class KeywordFilterGroup < ApplicationRecord
  belongs_to :server_setting, class_name: "ServerSetting", optional: true
  has_many :keyword_filters, dependent: :destroy
  accepts_nested_attributes_for :keyword_filters,
                                allow_destroy: true,
                                reject_if: proc { |att| att['keyword'].blank? }

  validates :name, presence: true
end
