class KeywordFilterGroup < ApplicationRecord
  belongs_to :server_setting, class_name: 'ServerSetting', optional: true
  has_many :keyword_filters, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :server_setting_id }

  accepts_nested_attributes_for :keyword_filters,
                                allow_destroy: true,
                                reject_if: proc { |attributes| attributes['keyword'].blank? }

  def self.fetch_keyword_filter_group_api(server_setting_name)
    server_setting_id = ServerSetting.where(name: server_setting_name).last&.id
    api_service = KeywordFilterGroupApiService.new('keyword_filter_groups')
    new_data = api_service.get_keywords

    new_data.each do |keyword_filter_group_data|
      filter_group = KeywordFilterGroup.find_or_initialize_by(
        name: keyword_filter_group_data['name'],
        is_custom: false
      )
      filter_group.assign_attributes(
        server_setting_id: server_setting_id,
        is_active: keyword_filter_group_data['is_active']
      )
      filter_group.save

      new_keywords = keyword_filter_group_data['keyword_filters'].map do |keyword_filter_data|
        keyword_filter = KeywordFilter.find_or_initialize_by(
          keyword: keyword_filter_data['keyword'],
          keyword_filter_group_id: filter_group.id
        )
        keyword_filter.assign_attributes(
          filter_type: keyword_filter_data['filter_type']
        )
        keyword_filter.save
        keyword_filter.keyword
      end

      filter_group.keyword_filters.where.not(keyword: new_keywords).destroy_all
    end

    new_group_names = new_data.map { |group| group['name'] }
    KeywordFilterGroup.where(is_custom: false).where.not(name: new_group_names).destroy_all
  end

  def self.delete_all_when_inactive(server_setting_id)
    content_filter = ServerSetting.find_by_id(server_setting_id)

    return unless content_filter.present? && content_filter.value == false

    KeywordFilterGroup.where(server_setting_id: server_setting_id).where(is_custom: false).destroy_all
  end
end
