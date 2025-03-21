module How
  module ContextGatherer
    def self.get_info(tool)
      outputs = []
      # Try standard help flag:
      outputs << run_command("#{tool} --help")
      # Try shorthand flags:
      outputs << run_command("#{tool} -h")
      outputs << run_command("#{tool} -?")
      # Try the man page:
      outputs << run_command("man #{tool}")
      # Filter out any empty outputs and combine results.
      outputs.compact.join("\n---\n")
    end

    def self.run_command(command)
      result = `#{command} 2>&1`
      result unless result.empty?
    rescue => e
      "Error executing #{command}: #{e.message}"
    end
  end
end