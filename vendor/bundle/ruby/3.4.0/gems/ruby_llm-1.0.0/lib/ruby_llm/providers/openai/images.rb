# frozen_string_literal: true

module RubyLLM
  module Providers
    module OpenAI
      # Image generation methods for the OpenAI API integration
      module Images
        module_function

        def images_url
          'images/generations'
        end

        def render_image_payload(prompt, model:, size:)
          {
            model: model,
            prompt: prompt,
            n: 1,
            size: size
          }
        end

        def parse_image_response(response)
          data = response.body
          image_data = data['data'].first

          Image.new(
            url: image_data['url'],
            mime_type: 'image/png', # DALL-E typically returns PNGs
            revised_prompt: image_data['revised_prompt'],
            model_id: data['model']
          )
        end
      end
    end
  end
end
