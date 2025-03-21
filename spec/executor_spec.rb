require 'spec_helper'

RSpec.describe How::Executor do
  describe '.execute' do
    it 'executes the provided command' do
      allow(How::Executor).to receive(:system).and_return(true)
      expect { How::Executor.execute('echo "test"') }.to output(/Executing: echo "test"/).to_stdout
    end
  end
end