require 'yaml'

module How
  module Config
    CONFIG_PATH = File.join(Dir.home, ".how", "config.yml")

    def self.api_token
      ENV['LLM_API_TOKEN'] || read_config["llm_api_token"]
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