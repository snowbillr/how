require 'yaml'

module How
  module Config
    CONFIG_PATH = File.join(Dir.home, ".how", "config.yml")

    def self.api_token
      ENV['LLM_API_TOKEN'] || read_config["llm_api_token"]
    end

    # New methods for ruby_llm gem compatibility
    def self.openai_api_key
      ENV['OPENAI_API_KEY'] || read_config["openai_api_key"] || api_token
    end

    def self.anthropic_api_key
      ENV['ANTHROPIC_API_KEY'] || read_config["anthropic_api_key"] || api_token
    end

    def self.gemini_api_key
      ENV['GEMINI_API_KEY'] || read_config["gemini_api_key"] || api_token
    end

    def self.deepseek_api_key
      ENV['DEEPSEEK_API_KEY'] || read_config["deepseek_api_key"] || api_token
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