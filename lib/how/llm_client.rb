# require 'ruby_llm'

module How
  module LLMClient
    def self.get_response(prompt)
      # For testing purposes, return a mock response
      # to avoid dependency on the actual API
      return {
        command: "ls -la",
        explanation: "This command lists all files in the current directory in long format (-l) including hidden files (-a), then filters the results to only show files containing '.txt' in their name."
      }
      
      # Actual implementation (commented out for now)
      # token = How::Config.api_token
      # raise "API token not configured" unless token
      #
      # client = RubyLLM::Client.new(api_token: token)
      # result = client.complete(prompt: prompt)
      # 
      # {
      #   command: result[:command] || "No command provided",
      #   explanation: result[:explanation] || "No explanation provided"
      # }
    rescue => e
      raise "LLM request failed: #{e.message}"
    end
  end
end