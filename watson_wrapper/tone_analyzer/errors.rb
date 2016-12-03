module WatsonWrapper
  module Errors
    class InvalidContentTypeError < StandardError
      def initialize(invalid_content_type)
        super "\"#{invalid_content_type}\" is not a valid Content-Type."
      end
    end

    class InvalidTonesError < StandardError
      def initialize(invalid_tone)
        super "\"#{invalid_tone}\" is not a valid tone."
      end
    end

    class InvalidSentenceAnalysisValueError < StandardError
      def initialize(sentence_analysis_val)
        super "#{sentence_analysis_value} is not a valid \"sentence_analysis\" value. Must evaluate to 'true' or 'false'."
      end
    end

    class InvalidTextLengthError < StandardError
      def initialize
        super "Analyzed text must have 3 words or more."
      end
    end

    class InvalidAllowDataCollectionError < StandardError
      def initialize(allow_data_collection_val)
        super "#{allow_data_collection_val} is not a valid \"allow_data_collection\" value.Must evaluate to 'true' or 'false'."
      end
    end
  end
end