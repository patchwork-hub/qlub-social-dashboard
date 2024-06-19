class KeywordFilterGroup < ApplicationRecord
  belongs_to :server_setting, class_name: 'ServerSetting', optional: true
  has_many :keyword_filters, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :server_setting_id }

  accepts_nested_attributes_for :keyword_filters,
                                allow_destroy: true,
                                reject_if: proc { |attributes| attributes['keyword'].blank? }

  def self.fetch_keyword_filter_group_api(setting_name, server_setting_id)
    new_data = fetch_data_from_api(setting_name)
    filter_type = filter_type_for(setting_name)

    new_data.each do |group_data|
      filter_group = find_or_initialize_filter_group(group_data, server_setting_id)
      filter_group.update(is_active: group_data['is_active'])

      new_keywords = update_or_create_keywords(group_data[filter_type], filter_group)
      filter_group.keyword_filters.where.not(keyword: new_keywords).destroy_all
    end

    cleanup_old_groups(new_data, server_setting_id)
  end

  def self.delete_all_when_inactive(server_setting)
    KeywordFilterGroup.where(server_setting_id: server_setting.id, is_custom: false).destroy_all
  end

  private

  def self.fetch_data_from_api(setting_name)
    api_service = KeywordFilterGroupApiService.new(setting_name)
    api_service.get_keywords
  end

  def self.filter_type_for(setting_name)
    setting_name == 'Spam filters' ? 'spam_filters' : 'keyword_filters'
  end

  def self.find_or_initialize_filter_group(group_data, server_setting_id)
    KeywordFilterGroup.find_or_initialize_by(
      name: group_data['name'],
      server_setting_id: server_setting_id,
      is_custom: false
    )
  end

  def self.update_or_create_keywords(keywords_data, filter_group)
    keywords_data.map do |keyword_data|
      keyword_filter = KeywordFilter.find_or_initialize_by(
        keyword: keyword_data['keyword'],
        keyword_filter_group_id: filter_group.id
      )
      keyword_filter.update(filter_type: keyword_data['filter_type'])
      keyword_filter.keyword
    end
  end

  def self.cleanup_old_groups(new_data, server_setting_id)
    new_group_names = new_data.map { |group| group['name'] }
    KeywordFilterGroup.where(server_setting_id: server_setting_id, is_custom: false)
                      .where.not(name: new_group_names)
                      .destroy_all
  end
end
