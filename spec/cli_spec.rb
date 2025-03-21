require 'spec_helper'

RSpec.describe How::CLI do
  # Add CLI testing
  it "has an explain command" do
    expect(How::CLI.commands.keys).to include("explain")
  end
end