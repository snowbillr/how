# frozen_string_literal: true

module RubyLLM
  module Providers
    # DeepSeek API integration.
    module DeepSeek
      extend OpenAI

      module_function

      def api_base
        'https://api.deepseek.com'
      end

      def headers
        {
          'Authorization' => "Bearer #{RubyLLM.config.deepseek_api_key}"
        }
      end

      def capabilities
        DeepSeek::Capabilities
      end

      def slug
        'deepseek'
      end
    end
  end
end
