require 'singleton'
require 'net/http'
require 'uri'
require 'json'
require 'pry'

module WatsonWrapper
  class InvalidContentTypeError < StandardError; end
  class InvalidTonesError < StandardError; end
  class ToneAnalyzer
    include Singleton

    attr_writer :user, :password, :content_type, :sentences, :allow_data_collection

    def tones=(*tones)
      @tones = tones
    end

    def self.configure(&block)
      self.instance.configure &block
    end

    def configure
      set_data
      yield self
      self
    end

    def get(text)
      @text = text 
      uri = URI.parse(build_get_uri)

      req = Net::HTTP::Get.new uri
      if @allow_data_collection
        req.add_field('X-Watson-Learning-Opt-Out', '1')
      end
      req.basic_auth @user, @password

      res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        http.request(req)
      end

      JSON.parse(res.body)
    end

    def post(text)
      @text = text
      uri = URI.parse(base_uri)

      req = Net::HTTP::Post.new(uri, 'Content-Type': @content_type)
      req.body = @text
      req.basic_auth @user, @password

      res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        http.request(req)
      end


      JSON.parse(res.body)
    end

    private

    def set_data
      @version = 'v3'
      @version_date = '2016-05-19'

      @endpoint = "https://gateway.watsonplatform.net/tone-analyzer/api/#{@version}/tone"

      # TODO: Raise an exception if no valid content type
      @valid_content_types = ['text/plain', 'text/html', 'application/json']

      # Set a @tones_param to filter results on a specific tone, otherwise
      # results will contain all tones
      @valid_tones = ['emotion', 'language', 'social']
      @tones = []

      # Set to true to remove sentence-level analysis, otherwise results will
      # contain sentence-level analysis
      # TODO: Should I raise an exception if @sentences' string form not 'true'
      # or 'false'?
      @sentences = false

      # Set to true if you do not want Watson to collect your data to improve its
      # service.
      @allow_data_collection = false

      # Text must be at least three words long to perform an analysis
      # TODO: Raise an exception if this is not the case
      @text = ''
    end

    def build_get_uri
      base_uri + '&' + "text=#{text}"
    end

    def base_uri
      @endpoint + '?' +
        "version=#{@version_date}&" +
        "tones=#{tones}&" +
        "sentences=#{sentences}"
    end

    def sentences
      @sentences.to_s
    end

    def tones
      @tones.join(',')
    end

    def text
      @text
    end
  end
end

# {
#   "url": "https://gateway.watsonplatform.net/tone-analyzer/api",
#   "password": "FdUoTWvpaFsd",
#   "username": "8ddf8228-bfa7-4ff0-b135-fcc4517bf776"
# }

analyzer = WatsonWrapper::ToneAnalyzer.configure do |config|
  config.user = '8ddf8228-bfa7-4ff0-b135-fcc4517bf776'
  config.password = 'FdUoTWvpaFsd'
  config.content_type = 'text/plain'
  config.tones = 'emotion'
end

puts analyzer.get("How could you let this happen!")