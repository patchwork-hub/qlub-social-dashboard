class KeywordFilterGroupApiService 
  require 'httparty'
  
  def initialize(action_name)
      @base_url = "https://hub.patchwork.online/api/v1/#{action_name}"
      @api_key = "8e225f965e51445fd5e27c5870111481"
  end
  
  def get_keywords
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
      Rails.logger.error("Failed to get access token: #{e}")
      []
    end
  end
end