require 'fileutils'
require 'rainbow'

module How
  class CLI < Thor
    no_commands do
      def self.exit_on_failure?
        true
      end
    end

    desc 'config [MODEL] [API_KEY]', 'Set the model and API key in the configuration file'
    def config(option, value)
      config_path = File.join(Dir.home, '.how', 'config.yml')
      config = File.exist?(config_path) ? YAML.load_file(config_path) : {}

      valid_options = %w[model openai_api_key anthropic_api_key gemini_api_key deepseek_api_key]
      if !valid_options.include?(option)
        puts Rainbow("Invalid option. Valid options are: #{valid_options.join(', ')}").red
        return
      end

      config[option] = value

      FileUtils.mkdir_p(File.dirname(config_path))
      File.write(config_path, config.to_yaml)
      puts Rainbow("Configuration updated: #{option}=#{value}").green
    end

    desc "[TOOL] [TASK_DESCRIPTION]", "Explain how to use TOOL to accomplish TASK_DESCRIPTION"
    def method_missing(method_name, *args)
      tool = method_name.to_s
      task = args.join(" ")
      
      # If task starts with "how", remove it
      task = task.sub(/^how\s+/, '') if task.start_with?("how ")
      
      # 1. Gather context from the tool using various help commands.
      context = How::ContextGatherer.get_info(tool)
      
      # 2. Build prompt for the LLM.
      prompt = "Using the following context:\n#{context}\nExplain how to #{task}"
      
      # 3. Get LLM response using ruby-llm.
      response = How::LLMClient.get_response(prompt)
      
      # 4. Display response and ask for confirmation.
      puts Rainbow("Proposed Operation:").white.bright
      puts Rainbow(response[:command]).yellow
      puts "\n"
      puts Rainbow("Explanation:").white.bright
      puts Rainbow(response[:explanation]).white

      print Rainbow("Execute this command? (y/n): ").yellow
      answer = $stdin.gets.chomp.downcase
      
      if answer == 'y'
        How::Executor.execute(response[:command])
      else
        puts Rainbow("Aborted.").red
      end
    rescue => e
      puts Rainbow("Error: #{e.message}").red
    end
  end
end