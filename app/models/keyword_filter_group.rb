class KeywordFilterGroup < ApplicationRecord
  belongs_to :server_setting, class_name: "ServerSetting", optional: true
  has_many :keyword_filters, dependent: :destroy
  accepts_nested_attributes_for :keyword_filters,
                                allow_destroy: true,
                                reject_if: proc { |att| att['keyword'].blank? }

  validates :name, presence: true, uniqueness: true

  def fetch_keyword_filter_group_api
    server_setting_id = ServerSetting.where(name: "Content filters").last&.id

    KeywordFilterGroupApiService.new("keyword_filter_groups").get_keywords.each do |keyword_filter_group|

      filter_group = KeywordFilterGroup.new(
          name: keyword_filter_group['name'],
          is_custom: keyword_filter_group['is_custom'],
          server_setting_id: server_setting_id,
          is_active: keyword_filter_group['is_active'],
      )
      filter_group.save

      keyword_filter_group['keyword_filters'].each do |keyword_filter|
        keyword = KeywordFilter.new(
          keyword: keyword_filter['keyword'],
          is_active: keyword_filter['is_active'],
          filter_type: keyword_filter['filter_type'],
          keyword_filter_group_id: filter_group.id
        )
        keyword.save
      end

    end
  end

  def fetch_keywords_job

    content_filter = ServerSetting.find_by(name: "Content filters")

    return unless content_filter.present?

    KeywordFilterGroup.where(is_custom: false).destroy_all if KeywordFilterGroup.where(is_custom: false).exists?

    KeywordFilterGroup.new.fetch_keyword_filter_group_api if content_filter.value
  end

end
