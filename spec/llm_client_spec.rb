require 'spec_helper'

RSpec.describe How::LLMClient do
  describe '.get_response' do
    it 'returns a response with command and explanation' do
      mock_client = double("RubyLLM::Client")
      allow(How::Config).to receive(:api_token).and_return("mock_token")
      allow(RubyLLM::Client).to receive(:new).and_return(mock_client)
      allow(mock_client).to receive(:complete).and_return({command: "ls -la", explanation: "List all files"})
      
      response = How::LLMClient.get_response("test prompt")
      expect(response[:command]).to eq("ls -la")
      expect(response[:explanation]).to eq("List all files")
    end
  end
end