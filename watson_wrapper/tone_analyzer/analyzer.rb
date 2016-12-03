require 'pry'

module WatsonWrapper
  module ToneAnalyzer
    class Analyzer
      include Singleton

      attr_writer :user, :password, :content_type, :sentence_analysis,
        :allow_data_collection

      def self.configure(&block)
        self.instance.configure &block
      end

      def configure
        set_data
        yield self
        validate_parameters
        self
      end

      def tones=(*tones)
        @tones = tones
      end

      def get(text)
        @text = text 
        valid_text_length?
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

      def post(payload)
        @text = payload 
        valid_text_length?
        uri = URI.parse(base_uri)

        req = Net::HTTP::Post.new(uri, 'Content-Type': @content_type)
        if @allow_data_collection
          req.add_field('X-Watson-Learning-Opt-Out', '1')
        end
        req.body = text_as_payload
        req.basic_auth @user, @password

        res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
          http.request(req)
        end

        JSON.parse(res.body)
      end

      private

      def validate_parameters
        valid_tones?
        valid_content_type?
        valid_sentence_analysis_value?
        valid_allow_data_collection_value?
      end

      def valid_tones?
        if !@tones.empty?
          @tones.each do |tone|
            raise InvalidTonesError.new tone unless @valid_tones.include? tone
          end
        end
      end

      def valid_content_type?
        if !@valid_content_types.include?(@content_type)
          raise Error:InvalidContentTypeError.new(@content_type)
        end
      end

      def valid_sentence_analysis_value?
        if ![true, false, 'true', 'false'].include? @sentence_analysis
          raise InvalidSentenceAnalysisTypeError.new @sentence_analysis
        end
      end

      def valid_text_length?
        raise Errors::InvalidTextLengthError.new if @text.split(' ').size < 3
      end

      def valid_allow_data_collection_value?
        if ![true, false, 'true', 'false'].include? @allow_data_collection
          raise InvalidSentenceAnalysisTypeError.new @allow_data_collection
        end
      end

      def set_data
        @version = 'v3'
        @version_date = '2016-05-19'

        @endpoint = "https://gateway.watsonplatform.net/tone-analyzer/api/#{@version}/tone"

        @valid_content_types = ['text/plain', 'text/html', 'application/json']
        @content_type = 'text/plain'

        # Set a @tones_param to filter results on a specific tone, otherwise
        # results will contain all tones
        @valid_tones = ['emotion', 'language', 'social']
        @tones = []

        # Set to true to remove sentence-level analysis, otherwise results will
        # contain sentence-level analysis
        @sentence_analysis = false

        # Set to true if you do not want Watson to collect your data to improve its
        # service.
        @allow_data_collection = false

        # Text must be at least three words long to perform an analysis
        # TODO: Raise an exception if this is not the case
        @text = ''
      end

      def build_get_uri
        base_uri + '&' + "text=#{@text}"
      end

      def base_uri
        @endpoint + '?' +
          "version=#{@version_date}&" +
          "tones=#{tones}&" +
          "sentences=#{sentences}"
      end

      def sentences
        @sentence_analysis.to_s
      end

      def tones
        @tones.join(',')
      end

      def text_as_payload
        @content_type == 'application/json' ? {text: @text}.to_json : @text
      end
    end
  end
end