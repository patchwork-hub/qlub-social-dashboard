class KeywordFilterApiService 
  require 'httparty'
  
  def initialize  
      @base_url = "http://localhost:3001/api/v1/keyword_filters"
      @api_key = "af6cb5720887e08ca3c492b1f2f16f6d"
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