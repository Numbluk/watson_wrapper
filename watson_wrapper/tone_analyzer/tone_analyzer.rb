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
#   "password": 
#   "username": 
# }

analyzer = WatsonWrapper::ToneAnalyzer.configure do |config|
  config.user = # need to set
  config.password = # need to set
  config.content_type = 'application/json'
end

puts analyzer.post("How could you let this happen!")
