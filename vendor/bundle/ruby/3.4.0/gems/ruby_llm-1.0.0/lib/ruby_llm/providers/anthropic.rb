# frozen_string_literal: true

module RubyLLM
  module Providers
    # Anthropic Claude API integration. Handles the complexities of
    # Claude's unique message format and tool calling conventions.
    module Anthropic
      extend Provider
      extend Anthropic::Chat
      extend Anthropic::Embeddings
      extend Anthropic::Media
      extend Anthropic::Models
      extend Anthropic::Streaming
      extend Anthropic::Tools

      module_function

      def api_base
        'https://api.anthropic.com'
      end

      def headers
        {
          'x-api-key' => RubyLLM.config.anthropic_api_key,
          'anthropic-version' => '2023-06-01'
        }
      end

      def capabilities
        Anthropic::Capabilities
      end

      def slug
        'anthropic'
      end
    end
  end
end
