# How
A CLI tool that uses LLMs to explain how to use other command-line tools.

## Features
- Explain how to use various command-line tools
- Supports multiple LLM services (OpenAI, Anthropic, Gemini, DeepSeek)
- Easy configuration 

## Installation
1. Make sure you have Ruby installed. This project uses Ruby 3.4.2 (managed with asdf).
2. Clone this repository
3. Run `bundle install` to install dependencies

## Usage
```bash
# Get help on how to use a command
bin/how [TOOL] [TASK DESCRIPTION]
# Example
bin/how tar create a compressed archive of a directory
```

## Configuration
For production use, you'll need to set up an API token for an LLM service. You can use the `how config` command to set any of the following values. *Only one provider/key combo is required.*

```bash
# Set the OpenAI API key
bin/how config openai_api_key your_openai_api_key_here

# Set the Anthropic API key
bin/how config anthropic_api_key your_anthropic_api_key_here

# Set the Gemini API key
bin/how config gemini_api_key your_gemini_api_key_here

# Set the DeepSeek API key
bin/how config deepseek_api_key your_deepseek_api_key_here

# Set the preferred model
bin/how config model your_preferred_model_here
```

Alternatively, you can set the following environment variables:
- `HOW_OPENAI_API_KEY`
- `HOW_ANTHROPIC_API_KEY`
- `HOW_GEMINI_API_KEY`
- `HOW_DEEPSEEK_API_KEY`
- `HOW_MODEL`

The tool will use these keys to interact with the respective LLM services and model configuration.

To determine what models are available, run `RubyLLM.models.all` in a Ruby console.

## Development
Run the tests:
```bash
bundle exec rspec
```

## License
This project is licensed under the MIT License.