# How

A CLI tool that uses LLMs to explain how to use other command-line tools.

## Installation

1. Make sure you have Ruby installed. This project uses Ruby 3.3.1 (managed with asdf).
2. Clone this repository
3. Run `bundle install` to install dependencies

## Usage

```bash
# Get help on how to use a command
bin/how explain [TOOL] [TASK DESCRIPTION]

# Example
bin/how explain tar "create a compressed archive of a directory"
```

## Development

Run the tests:

```bash
bundle exec rspec
```

## Configuration

For production use, you'll need to set up API tokens for the LLM service:

1. Create a `.how` directory in your home folder: `mkdir -p ~/.how`
2. Create a `config.yml` file with your API tokens:

```yaml
openai_api_key: your_openai_api_key_here
anthropic_api_key: your_anthropic_api_key_here
gemini_api_key: your_gemini_api_key_here
deepseek_api_key: your_deepseek_api_key_here
```

Alternatively, you can set the following environment variables:

- `OPENAI_API_KEY`
- `ANTHROPIC_API_KEY`
- `GEMINI_API_KEY`
- `DEEPSEEK_API_KEY`

The tool will use these keys to interact with the respective LLM services.