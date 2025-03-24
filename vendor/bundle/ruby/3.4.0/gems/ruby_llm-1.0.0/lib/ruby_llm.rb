# frozen_string_literal: true

require 'base64'
require 'event_stream_parser'
require 'faraday'
require 'faraday/retry'
require 'json'
require 'logger'
require 'securerandom'
require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect(
  'ruby_llm' => 'RubyLLM',
  'llm' => 'LLM',
  'openai' => 'OpenAI',
  'api' => 'API',
  'deepseek' => 'DeepSeek'
)
loader.setup

# A delightful Ruby interface to modern AI language models.
# Provides a unified way to interact with models from OpenAI, Anthropic and others
# with a focus on developer happiness and convention over configuration.
module RubyLLM
  class Error < StandardError; end

  class << self
    def chat(model: nil)
      Chat.new(model: model)
    end

    def embed(...)
      Embedding.embed(...)
    end

    def paint(...)
      Image.paint(...)
    end

    def models
      Models.instance
    end

    def providers
      Provider.providers.values
    end

    def configure
      yield config
    end

    def config
      @config ||= Configuration.new
    end

    def logger
      @logger ||= Logger.new(
        $stdout,
        progname: 'RubyLLM',
        level: ENV['RUBYLLM_DEBUG'] ? Logger::DEBUG : Logger::INFO
      )
    end
  end
end

RubyLLM::Provider.register :openai, RubyLLM::Providers::OpenAI
RubyLLM::Provider.register :anthropic, RubyLLM::Providers::Anthropic
RubyLLM::Provider.register :gemini, RubyLLM::Providers::Gemini
RubyLLM::Provider.register :deepseek, RubyLLM::Providers::DeepSeek

if defined?(Rails::Railtie)
  require 'ruby_llm/railtie'
  require 'ruby_llm/active_record/acts_as'
end
