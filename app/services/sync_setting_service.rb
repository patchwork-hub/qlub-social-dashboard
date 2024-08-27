class SyncSettingService < BaseService
  def initialize(setting)
    @setting = setting
    @api_key = ApiKey.first
  end

  def call
    response = sync_with_external_service

    if response.success?
      Rails.logger.info "✅ Settings synced!"
    else
      Rails.logger.error "❌ Failed to sync settings: #{response.status}"
    end
  end

  private

  def sync_with_external_service
    conn = Faraday.new(
      url: ENV['PATCHWORK_HUB_URL'],
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': @api_key.key,
        'x-api-secret': @api_key.secret
      }
    )

    conn.post('/api/v1/server_settings/upsert', request_body.to_json)
  end

  def request_body
    {
      server_setting: {
        settings: [
          {
            name: @setting.parent.name,
            options: [
              {
                name: @setting.name,
                value: @setting.value,
                position: @setting.position
              }
            ]
          }
        ]
      }
    }
  end
end
