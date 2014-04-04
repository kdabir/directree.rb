require 'spec_helper'

describe Directree do
  it "should give current version" do
    (Directree::VERSION).should match("0.0.1")
  end
end