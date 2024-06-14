class KeywordFiltersJob < ApplicationJob
  queue_as :default

  def perform(server_setting_name)
    setting = ServerSetting.where(name: server_setting_name)&.last

    if setting.value == true
      KeywordFilterGroup.fetch_keyword_filter_group_api(server_setting_name)
    else
      KeywordFilterGroup.delete_all_when_inactive(server_setting_name) if KeywordFilterGroup.where(is_custom: false).exists?
    end
  end
end
