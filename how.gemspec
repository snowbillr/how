require_relative "lib/how"

Gem::Specification.new do |spec|
  spec.name        = "how"
  spec.version     = How::VERSION
  spec.authors     = ["Bill Reed"]
  spec.email       = ["snowbillr@gmail.com"]
  
  spec.summary     = "A CLI tool that uses LLMs to explain how to use other command-line tools"
  spec.description = "How is a command-line tool that leverages large language models to provide explanations and examples for using various command-line tools. It supports multiple LLM services including OpenAI, Anthropic, Gemini, and DeepSeek."
  spec.homepage    = "https://github.com/snowbillr/how"
  spec.license     = "MIT"
  
  spec.required_ruby_version = ">= 3.0.0"
  
  spec.files = Dir["lib/**/*", "bin/*", "README.md", "LICENSE", "RUBY_LLM_INFO.md"]
  spec.bindir = "bin"
  spec.executables = ["how"]
  
  spec.add_dependency "thor", "~> 1.0"
  spec.add_dependency "ruby_llm", "~> 0.1"
  spec.add_dependency "base64", "~> 0.1"
  spec.add_dependency "rainbow", "~> 3.0"
  
  spec.add_development_dependency "rspec", "~> 3.10"
end