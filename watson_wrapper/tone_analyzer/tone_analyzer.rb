require 'singleton'
require 'net/http'
require 'uri'
require 'json'
require 'pry'
require './errors'
require './analyzer'

module WatsonWrapper
  module ToneAnalyzer
    def self.method_missing(mthd, *args, &block)
      Analyzer.public_send(mthd, *args, &block)
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
  config.content_type = 'application/json'
end

puts analyzer.post("How could you let this happen!")