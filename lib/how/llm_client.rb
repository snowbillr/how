require 'ruby_llm'

module How
  module LLMClient
    def self.get_response(prompt)
      # Check if testing mode is enabled
      if ENV['HOW_TEST_MODE'] == 'true'
        return {
          command: "ls -la",
          explanation: "This command lists all files in the current directory in long format (-l) including hidden files (-a), then filters the results to only show files containing '.txt' in their name."
        }
      end
      
      # Configure RubyLLM with API keys
      RubyLLM.configure do |config|
        config.openai_api_key = How::Config.openai_api_key
        config.anthropic_api_key = How::Config.anthropic_api_key
        config.gemini_api_key = How::Config.gemini_api_key
        config.deepseek_api_key = How::Config.deepseek_api_key
      end
      
      # Check if at least one API key is configured
      if How::Config.openai_api_key.nil? && How::Config.anthropic_api_key.nil? && 
         How::Config.gemini_api_key.nil? && How::Config.deepseek_api_key.nil?
        raise "No LLM API token configured. Please set up an API token in ~/.how/config.yml or environment variables."
      end
      
      # Start a chat with the default model (usually GPT-4o-mini)
      chat = RubyLLM.chat
      
      # Structure the prompt to get command and explanation
      formatted_prompt = <<~PROMPT
        You are a command-line expert. Based on the following context about a CLI tool 
        and the user's task, provide:
        1. The exact command to execute the task
        2. A clear explanation of what the command does

        CONTEXT:
        #{prompt}

        Respond in this JSON format only:
        {
          "command": "the exact command to run",
          "explanation": "explanation of what the command does"
        }
      PROMPT
      
      # Get a response from the LLM
      response = chat.ask(formatted_prompt)
      
      # Try to parse the JSON response
      begin
        # The response might be in a code block, so extract it if necessary
        json_text = response.to_s
        if json_text =~ /```(?:json)?\s*(\{.*?\})\s*```/m
          json_text = $1
        end
        
        result = JSON.parse(json_text, symbolize_names: true)
        
        # Ensure we have the expected keys
        {
          command: result[:command] || "No command provided",
          explanation: result[:explanation] || "No explanation provided"
        }
      rescue => e
        # If parsing fails, try to extract command and explanation more manually
        command_match = response.to_s.match(/command"?\s*:?\s*"?([^"\n]+)"?/i)
        explanation_match = response.to_s.match(/explanation"?\s*:?\s*"?([^"]+)"?/i)
        
        {
          command: command_match ? command_match[1].strip : "Failed to parse command",
          explanation: explanation_match ? explanation_match[1].strip : "Failed to parse explanation"
        }
      end
    rescue => e
      raise "LLM request failed: #{e.message}"
    end
  end
end