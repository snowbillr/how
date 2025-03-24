require 'fileutils'
require 'rainbow'
require 'yaml'
require 'ruby_llm'

module How
  class CLI < Thor
    no_commands do
      def self.exit_on_failure?
        true
      end
    end

    desc 'config [OPTION] [VALUE]', 'Set the model and API key in the configuration file. Valid options are `model`, `openai_api_key`, `anthropic_api_key`, `gemini_api_key`, and `deepseek_api_key`. With no arguments, runs in interactive mode.'
    def config(option = nil, value = nil)
      config_path = File.join(Dir.home, '.how', 'config.yml')
      config = File.exist?(config_path) ? YAML.load_file(config_path) : {}
      
      puts "Let's set up your 'how' configuration."
      
      # Filter and get available AI models from supported providers
      puts Rainbow("\nChoose a model:").yellow
      
      # Get all models grouped by provider
      supported_providers = ['openai', 'anthropic', 'gemini', 'deepseek']
      all_models = RubyLLM.models.all
      
      provider_models = {}
      model_list = []
      
      supported_providers.each do |provider|
        models = all_models.select { |m| m.provider == provider }.map(&:id)
        provider_models[provider] = models
        
        unless models.empty?
          puts Rainbow("\n#{provider.capitalize} Models:").white.bright
          models.each_with_index do |model, i|
            model_list << model
            puts "  #{model_list.length}. #{model}"
          end
        end
      end
      
      # Get user choice
      print Rainbow("\nEnter the number of your preferred model: ").cyan
      model_number = $stdin.gets.chomp.to_i
      
      if model_number < 1 || model_number > model_list.length
        puts Rainbow("Invalid selection. Configuration aborted.").red
        return
      end
      
      selected_model = model_list[model_number - 1]
      selected_provider = nil
      
      # Determine provider from the selected model
      supported_providers.each do |provider|
        if provider_models[provider].include?(selected_model)
          selected_provider = provider
          break
        end
      end
      
      puts Rainbow("\nYou selected: #{selected_model} (#{selected_provider})").green
      
      # Ask for the corresponding API key
      print Rainbow("\nEnter your #{selected_provider} API key: ").cyan
      api_key = $stdin.gets.chomp
      
      # Update the configuration
      config["model"] = selected_model
      config["#{selected_provider}_api_key"] = api_key
      
      # Save configuration
      FileUtils.mkdir_p(File.dirname(config_path))
      File.write(config_path, config.to_yaml)
      
      puts Rainbow("\nConfiguration updated successfully!").green
      puts Rainbow("  Model: #{selected_model}").white
      puts Rainbow("  #{selected_provider}_api_key: #{api_key[0..5]}...").white
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
      puts "\n"

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