require 'yaml'

module How
  module Config
    CONFIG_PATH = File.join(Dir.home, ".how", "config.yml")

    def self.openai_api_key
      ENV['HOW_OPENAI_API_KEY'] || read_config["openai_api_key"] || nil
    end

    def self.anthropic_api_key
      ENV['HOW_ANTHROPIC_API_KEY'] || read_config["anthropic_api_key"] || nil
    end

    def self.gemini_api_key
      ENV['HOW_GEMINI_API_KEY'] || read_config["gemini_api_key"] || nil
    end

    def self.deepseek_api_key
      ENV['HOW_DEEPSEEK_API_KEY'] || read_config["deepseek_api_key"] || nil
    end

    def self.model
      ENV['HOW_MODEL'] || read_config["model"] || nil
    end

    def self.read_config
      if File.exist?(CONFIG_PATH)
        YAML.load_file(CONFIG_PATH)
      else
        {}
      end
    rescue => e
      puts "Error reading config: #{e.message}"
      {}
    end
  end
end