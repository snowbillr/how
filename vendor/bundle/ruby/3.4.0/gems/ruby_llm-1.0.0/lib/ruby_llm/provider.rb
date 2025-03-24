# frozen_string_literal: true

module RubyLLM
  # Base interface for LLM providers like OpenAI and Anthropic.
  # Handles the complexities of API communication, streaming responses,
  # and error handling so individual providers can focus on their unique features.
  module Provider
    # Common functionality for all LLM providers. Implements the core provider
    # interface so specific providers only need to implement a few key methods.
    module Methods # rubocop:disable Metrics/ModuleLength
      def complete(messages, tools:, temperature:, model:, &block)
        payload = render_payload messages, tools: tools, temperature: temperature, model: model, stream: block_given?

        if block_given?
          stream_response payload, &block
        else
          sync_response payload
        end
      end

      def list_models
        response = connection.get(models_url) do |req|
          req.headers.merge! headers
        end

        parse_list_models_response response, slug, capabilities
      end

      def embed(text, model:)
        payload = render_embedding_payload text, model: model
        response = post embedding_url, payload
        parse_embedding_response response
      end

      def paint(prompt, model:, size:)
        payload = render_image_payload(prompt, model:, size:)

        response = post(images_url, payload)
        parse_image_response(response)
      end

      private

      def sync_response(payload)
        response = post completion_url, payload
        parse_completion_response response
      end

      def stream_response(payload, &block)
        accumulator = StreamAccumulator.new

        post stream_url, payload do |req|
          req.options.on_data = handle_stream do |chunk|
            accumulator.add chunk
            block.call chunk
          end
        end

        accumulator.to_message
      end

      def post(url, payload)
        connection.post url, payload do |req|
          req.headers.merge! headers
          yield req if block_given?
        end
      end

      def connection # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
        @connection ||= Faraday.new(api_base) do |f| # rubocop:disable Metrics/BlockLength
          f.options.timeout = RubyLLM.config.request_timeout

          f.response :logger,
                     RubyLLM.logger,
                     bodies: true,
                     response: true,
                     errors: true,
                     headers: false,
                     log_level: :debug do |logger|
            logger.filter(%r{"[A-Za-z0-9+/=]{100,}"}, 'data":"[BASE64 DATA]"')
            logger.filter(/[-\d.e,\s]{100,}/, '[EMBEDDINGS ARRAY]')
          end

          f.request :retry, {
            max: RubyLLM.config.max_retries,
            interval: 0.05,
            interval_randomness: 0.5,
            backoff_factor: 2,
            exceptions: [
              Errno::ETIMEDOUT,
              Timeout::Error,
              Faraday::TimeoutError,
              Faraday::ConnectionFailed,
              Faraday::RetriableResponse,
              RubyLLM::RateLimitError,
              RubyLLM::ServerError,
              RubyLLM::ServiceUnavailableError
            ],
            retry_statuses: [429, 500, 502, 503, 504]
          }

          f.request :json
          f.response :json
          f.adapter Faraday.default_adapter
          f.use :llm_errors, provider: self
        end
      end

      def to_json_stream(&block) # rubocop:disable Metrics/MethodLength
        buffer = String.new
        parser = EventStreamParser::Parser.new

        proc do |chunk, _bytes, env|
          if env && env.status != 200
            # Accumulate error chunks
            buffer << chunk
            begin
              error_data = JSON.parse(buffer)
              error_response = env.merge(body: error_data)
              ErrorMiddleware.parse_error(provider: self, response: error_response)
            rescue JSON::ParserError
              # Keep accumulating if we don't have complete JSON yet
              RubyLLM.logger.debug "Accumulating error chunk: #{chunk}"
            end
          else
            parser.feed(chunk) do |_type, data|
              unless data == '[DONE]'
                parsed_data = JSON.parse(data)
                block.call(parsed_data)
              end
            end
          end
        end
      end
    end

    def try_parse_json(maybe_json)
      return maybe_json unless maybe_json.is_a?(String)

      JSON.parse(maybe_json)
    rescue JSON::ParserError
      maybe_json
    end

    def parse_error(response) # rubocop:disable Metrics/MethodLength
      return if response.body.empty?

      body = try_parse_json(response.body)
      case body
      when Hash
        body.dig('error', 'message')
      when Array
        body.map do |part|
          part.dig('error', 'message')
        end.join('. ')
      else
        body
      end
    end

    def parse_data_uri(uri)
      if uri&.start_with?('data:')
        match = uri.match(/\Adata:([^;]+);base64,(.+)\z/)
        return { mime_type: match[1], data: match[2] } if match
      end

      # If it's not a data URI, return nil
      nil
    end

    class << self
      def extended(base)
        base.extend(Methods)
      end

      def register(name, provider_module)
        providers[name.to_sym] = provider_module
      end

      def for(model)
        model_info = Models.find(model)
        providers[model_info.provider.to_sym]
      end

      def providers
        @providers ||= {}
      end
    end
  end
end
