# frozen_string_literal: true

module RubyLLM
  # A single message in a chat conversation. Can represent user input,
  # AI responses, or tool interactions. Tracks token usage and handles
  # the complexities of tool calls and responses.
  class Message
    ROLES = %i[system user assistant tool].freeze

    attr_reader :role, :content, :tool_calls, :tool_call_id, :input_tokens, :output_tokens, :model_id

    def initialize(options = {})
      @role = options[:role].to_sym
      @content = normalize_content(options[:content])
      @tool_calls = options[:tool_calls]
      @input_tokens = options[:input_tokens]
      @output_tokens = options[:output_tokens]
      @model_id = options[:model_id]
      @tool_call_id = options[:tool_call_id]

      ensure_valid_role
    end

    def tool_call?
      !tool_calls.nil? && !tool_calls.empty?
    end

    def tool_result?
      !tool_call_id.nil? && !tool_call_id.empty?
    end

    def tool_results
      content if tool_result?
    end

    def to_h
      {
        role: role,
        content: content,
        tool_calls: tool_calls,
        tool_call_id: tool_call_id,
        input_tokens: input_tokens,
        output_tokens: output_tokens,
        model_id: model_id
      }.compact
    end

    private

    def normalize_content(content)
      case content
      when Content then content.format
      when String then Content.new(content).format
      else content
      end
    end

    def ensure_valid_role
      raise InvalidRoleError, "Expected role to be one of: #{ROLES.join(', ')}" unless ROLES.include?(role)
    end
  end
end
