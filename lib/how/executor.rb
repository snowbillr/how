require 'rainbow'

module How
  module Executor
    def self.execute(command)
      result = system(command)
      
      if !result
        puts Rainbow("⚠️ Command may have encountered issues (exit code: #{$?.exitstatus})").yellow
      end
    rescue => e
      puts Rainbow("❌ Execution failed: #{e.message}").red.bright
    end
  end
end