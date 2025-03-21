module How
  module Executor
    def self.execute(command)
      puts "Executing: #{command}"
      system(command)
    rescue => e
      puts "Execution failed: #{e.message}"
    end
  end
end