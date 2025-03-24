# frozen_string_literal: true

module RubyLLM
  module Providers
    module Anthropic
      # Chat methods of the OpenAI API integration
      module Chat
        private

        def completion_url
          '/v1/messages'
        end

        def render_payload(messages, tools:, temperature:, model:, stream: false)
          {
            model: model,
            messages: messages.map { |msg| format_message(msg) },
            temperature: temperature,
            stream: stream,
            max_tokens: RubyLLM.models.find(model).max_tokens
          }.tap do |payload|
            payload[:tools] = tools.values.map { |t| function_for(t) } if tools.any?
          end
        end

        def parse_completion_response(response)
          data = response.body
          content_blocks = data['content'] || []

          text_content = extract_text_content(content_blocks)
          tool_use = find_tool_use(content_blocks)

          build_message(data, text_content, tool_use)
        end

        def extract_text_content(blocks)
          text_blocks = blocks.select { |c| c['type'] == 'text' }
          text_blocks.map { |c| c['text'] }.join
        end

        def build_message(data, content, tool_use)
          Message.new(
            role: :assistant,
            content: content,
            tool_calls: parse_tool_calls(tool_use),
            input_tokens: data.dig('usage', 'input_tokens'),
            output_tokens: data.dig('usage', 'output_tokens'),
            model_id: data['model']
          )
        end

        def format_message(msg)
          if msg.tool_call?
            format_tool_call(msg)
          elsif msg.tool_result?
            format_tool_result(msg)
          else
            format_basic_message(msg)
          end
        end

        def format_basic_message(msg)
          {
            role: convert_role(msg.role),
            content: Media.format_content(msg.content)
          }
        end

        def convert_role(role)
          case role
          when :tool, :user then 'user'
          else 'assistant'
          end
        end

        def format_text_block(content)
          {
            type: 'text',
            text: content
          }
        end
      end
    end
  end
end
