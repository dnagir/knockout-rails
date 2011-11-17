require 'spec_helper'

describe Knockout do
  it "should have rails Engine" do
    ::Knockout::Engine.should_not be_nil
  end
end
