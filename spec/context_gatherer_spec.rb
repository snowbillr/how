require 'spec_helper'

RSpec.describe How::ContextGatherer do
  describe '.get_info' do
    it 'collects help information from a CLI tool' do
      # This is a simple mock test
      allow(How::ContextGatherer).to receive(:run_command).and_return("Mock help output")
      expect(How::ContextGatherer.get_info('test_tool')).to include("Mock help output")
    end
  end
end