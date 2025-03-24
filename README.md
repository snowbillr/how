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
For production use, you'll need to set up an API token for an LLM service. You can use the `bin/how config` command to set up your LLM provider.

Alternatively, you can set the following environment variables:
- `HOW_OPENAI_API_KEY`
- `HOW_ANTHROPIC_API_KEY`
- `HOW_GEMINI_API_KEY`
- `HOW_DEEPSEEK_API_KEY`
- `HOW_MODEL`

## Development
Run the tests:
```bash
bundle exec rspec
```

## License
This project is licensed under the MIT License.