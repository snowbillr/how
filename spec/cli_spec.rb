require 'spec_helper'

RSpec.describe How::CLI do
  it "responds to method_missing for the explain command" do
    cli = How::CLI.new
    expect(cli).to receive(:method_missing).with(:explain)
    cli.explain
  end
end