require 'spec_helper'

RSpec.describe How::LLMClient do
  describe '.get_response' do
    context 'when test mode is enabled' do
      before do
        allow(ENV).to receive(:[]).with('HOW_TEST_MODE').and_return('true')
      end
      
      it 'returns a mock response' do
        response = How::LLMClient.get_response("test prompt")
        expect(response[:command]).to eq("ls -la")
        expect(response[:explanation]).to include("lists all files")
      end
    end
    
    context 'with actual API integration' do
      before do
        allow(ENV).to receive(:[]).with('HOW_TEST_MODE').and_return(nil)
        
        # Mock RubyLLM configuration
        allow(RubyLLM).to receive(:configure)
        
        # Mock Config module
        allow(How::Config).to receive(:openai_api_key).and_return("mock_openai_key")
        allow(How::Config).to receive(:anthropic_api_key).and_return(nil)
        allow(How::Config).to receive(:gemini_api_key).and_return(nil)
        allow(How::Config).to receive(:deepseek_api_key).and_return(nil)
        
        # Mock chat instance
        @mock_chat = double("RubyLLM::Chat")
        allow(RubyLLM).to receive(:chat).and_return(@mock_chat)
      end
      
      it 'returns parsed JSON response' do
        json_response = '{"command": "ls -la", "explanation": "List all files"}'
        allow(@mock_chat).to receive(:ask).and_return(json_response)
        
        response = How::LLMClient.get_response("test prompt")
        expect(response[:command]).to eq("ls -la")
        expect(response[:explanation]).to eq("List all files")
      end
      
      it 'extracts JSON from code blocks' do
        code_block_response = "```json\n{\"command\": \"grep -r 'pattern' .\", \"explanation\": \"Search for pattern\"}\n```"
        allow(@mock_chat).to receive(:ask).and_return(code_block_response)
        
        response = How::LLMClient.get_response("test prompt")
        expect(response[:command]).to eq("grep -r 'pattern' .")
        expect(response[:explanation]).to eq("Search for pattern")
      end
      
      it 'falls back to regex extraction when JSON parsing fails' do
        text_response = "The command: tar -czvf archive.tar.gz directory\nThe explanation: Creates a compressed archive"
        allow(@mock_chat).to receive(:ask).and_return(text_response)
        
        response = How::LLMClient.get_response("test prompt")
        expect(response[:command]).to include("tar -czvf")
        expect(response[:explanation]).to include("Creates a compressed")
      end
    end
  end
end