# frozen_string_literal: true

module RubyLLM
  # Represents a generated image from an AI model.
  # Provides an interface to image generation capabilities
  # from providers like DALL-E and Gemini's Imagen.
  class Image
    attr_reader :url, :data, :mime_type, :revised_prompt, :model_id

    def initialize(url: nil, data: nil, mime_type: nil, revised_prompt: nil, model_id: nil)
      @url = url
      @data = data
      @mime_type = mime_type
      @revised_prompt = revised_prompt
      @model_id = model_id
    end

    def base64?
      !@data.nil?
    end

    # Returns the raw binary image data regardless of source
    def to_blob
      if base64?
        Base64.decode64(@data)
      else
        # Use Faraday instead of URI.open for better security
        response = Faraday.get(@url)
        response.body
      end
    end

    # Saves the image to a file path
    def save(path)
      File.binwrite(File.expand_path(path), to_blob)
      path
    end

    def self.paint(prompt, model: nil, size: '1024x1024')
      model_id = model || RubyLLM.config.default_image_model
      Models.find(model_id) # Validate model exists

      provider = Provider.for(model_id)
      provider.paint(prompt, model: model_id, size: size)
    end
  end
end
