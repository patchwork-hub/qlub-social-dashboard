class KeywordFilterApiService 
  require 'httparty'
  
  def initialize
      @base_url = "#{Rails.application.config.base_url}keyword_filters"
      @api_key = Rails.env.production? ? "8e225f965e51445fd5e27c5870111481" : ENV['CENTRAL_DASHBOARD_KEY']
  end
  
  def get_keywords_filters
    begin
      res = HTTParty.get(@base_url, 
        :body => {}.to_json,
        :headers => {"Content-Type" => "application/json",
                    "x-api-key" => @api_key
                    }
      )
      return [] if res.code != 200
      JSON.parse(res.body)
    rescue HTTParty::Error, SocketError, Timeout::Error,  Errno::ECONNREFUSED => e
      puts "errrrorororoor"
      Rails.logger.error("Failed to get access token: #{e}")
      []
    end
  end
end