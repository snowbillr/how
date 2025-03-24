# frozen_string_literal: true

module RubyLLM
  module Providers
    module OpenAI
      # Tools methods of the OpenAI API integration
      module Tools
        module_function

        def tool_for(tool) # rubocop:disable Metrics/MethodLength
          {
            type: 'function',
            function: {
              name: tool.name,
              description: tool.description,
              parameters: {
                type: 'object',
                properties: tool.parameters.transform_values { |param| param_schema(param) },
                required: tool.parameters.select { |_, p| p.required }.keys
              }
            }
          }
        end

        def param_schema(param)
          {
            type: param.type,
            description: param.description
          }.compact
        end

        def format_tool_calls(tool_calls) # rubocop:disable Metrics/MethodLength
          return nil unless tool_calls&.any?

          tool_calls.map do |_, tc|
            {
              id: tc.id,
              type: 'function',
              function: {
                name: tc.name,
                arguments: JSON.generate(tc.arguments)
              }
            }
          end
        end

        def parse_tool_calls(tool_calls, parse_arguments: true) # rubocop:disable Metrics/MethodLength
          return nil unless tool_calls&.any?

          tool_calls.to_h do |tc|
            [
              tc['id'],
              ToolCall.new(
                id: tc['id'],
                name: tc.dig('function', 'name'),
                arguments: if parse_arguments
                             JSON.parse(tc.dig('function',
                                               'arguments'))
                           else
                             tc.dig('function', 'arguments')
                           end
              )
            ]
          end
        end
      end
    end
  end
end
