module How
  class CLI < Thor
    no_commands do
      def self.exit_on_failure?
        true
      end
    end

    desc "[TOOL] [TASK_DESCRIPTION]", "Explain how to use TOOL to accomplish TASK_DESCRIPTION"
    def method_missing(method_name, *args)
      tool = method_name.to_s
      task = args.join(" ")
      
      # If task starts with "how", remove it
      task = task.sub(/^how\s+/, '') if task.start_with?("how ")
      
      # 1. Gather context from the tool using various help commands.
      context = How::ContextGatherer.get_info(tool)
      
      # 2. Build prompt for the LLM.
      prompt = "Using the following context:\n#{context}\nExplain how to #{task}"
      
      # 3. Get LLM response using ruby-llm.
      response = How::LLMClient.get_response(prompt)
      
      # 4. Display response and ask for confirmation.
      puts "Proposed Operation:\n#{response[:command]}"
      puts "Explanation:\n#{response[:explanation]}"
      print "Execute this command? (y/n): "
      answer = $stdin.gets.chomp.downcase
      
      if answer == 'y'
        How::Executor.execute(response[:command])
      else
        puts "Aborted."
      end
    rescue => e
      puts "Error: #{e.message}"
    end
  end
end