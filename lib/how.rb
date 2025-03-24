require "thor"
require_relative "how/cli"
require_relative "how/context_gatherer"
require_relative "how/llm_client"
require_relative "how/executor"
require_relative "how/config"

module How
  VERSION = "0.4.0"
end