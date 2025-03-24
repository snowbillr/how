# frozen_string_literal: true

module RubyLLM
  # Registry of available AI models and their capabilities. Provides a clean interface
  # to discover and work with models from different providers.
  #
  # Example:
  #   RubyLLM.models.all                                  # All available models
  #   RubyLLM.models.chat_models                          # Models that support chat
  #   RubyLLM.models.by_provider('openai').chat_models    # OpenAI chat models
  #   RubyLLM.models.find('claude-3')                     # Get info about a specific model
  class Models
    include Enumerable

    def self.instance
      @instance ||= new
    end

    def self.provider_for(model)
      Provider.for(model)
    end

    # Class method to refresh model data
    def self.refresh!
      models = RubyLLM.providers.flat_map(&:list_models).sort_by(&:id)
      @instance = new(models)
    end

    # Delegate class methods to the singleton instance
    class << self
      def method_missing(method, ...)
        if instance.respond_to?(method)
          instance.send(method, ...)
        else
          super
        end
      end

      def respond_to_missing?(method, include_private = false)
        instance.respond_to?(method, include_private) || super
      end
    end

    # Initialize with optional pre-filtered models
    def initialize(models = nil)
      @models = models || load_models
    end

    # Load models from the JSON file
    def load_models
      data = JSON.parse(File.read(File.expand_path('models.json', __dir__)))
      data.map { |model| ModelInfo.new(model.transform_keys(&:to_sym)) }
    rescue Errno::ENOENT
      [] # Return empty array if file doesn't exist yet
    end

    # Return all models in the collection
    def all
      @models
    end

    # Allow enumeration over all models
    def each(&)
      all.each(&)
    end

    # Find a specific model by ID
    def find(model_id)
      all.find { |m| m.id == model_id } or
        raise ModelNotFoundError, "Unknown model: #{model_id}"
    end

    # Filter to only chat models
    def chat_models
      self.class.new(all.select { |m| m.type == 'chat' })
    end

    # Filter to only embedding models
    def embedding_models
      self.class.new(all.select { |m| m.type == 'embedding' })
    end

    # Filter to only audio models
    def audio_models
      self.class.new(all.select { |m| m.type == 'audio' })
    end

    # Filter to only image models
    def image_models
      self.class.new(all.select { |m| m.type == 'image' })
    end

    # Filter models by family
    def by_family(family)
      self.class.new(all.select { |m| m.family == family.to_s })
    end

    # Filter models by provider
    def by_provider(provider)
      self.class.new(all.select { |m| m.provider == provider.to_s })
    end

    # Instance method to refresh models
    def refresh!
      self.class.refresh!
      # Return self for method chaining
      self
    end
  end
end
