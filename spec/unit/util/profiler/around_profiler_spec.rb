require 'spec_helper'
require 'puppet/util/profiler'

describe Puppet::Util::Profiler::AroundProfiler do
  let(:child) { TestAroundProfiler.new() }
  let(:profiler) { Puppet::Util::Profiler::AroundProfiler.new }

  before :each do
    profiler.add_profiler(child)
  end

  it "returns the value of the profiled segment" do
    retval = profiler.profile("Testing", ["testing"]) { "the return value" }

    retval.should == "the return value"
  end

  it "propagates any errors raised in the profiled segment" do
    expect do
      profiler.profile("Testing", ["testing"]) { raise "a problem" }
    end.to raise_error("a problem")
  end

  it "makes the description and the context available to the `start` and `finish` methods" do
    profiler.profile("Testing", ["testing"]) { }

    child.context.should == "Testing"
    child.description.should == "Testing"
  end

  it "calls finish even when an error is raised" do
    begin
      profiler.profile("Testing", ["testing"]) { raise "a problem" }
    rescue
      child.context.should == "Testing"
    end
  end

  it "supports multiple profilers" do
    profiler2 = TestAroundProfiler.new
    profiler.add_profiler(profiler2)
    profiler.profile("Testing", ["testing"]) {}

    child.context.should == "Testing"
    profiler2.context.should == "Testing"
  end

  class TestAroundProfiler
    attr_accessor :context, :description

    def start(description, metric_id)
      description
    end

    def finish(context, description, metric_id)
      @context = context
      @description = description
    end
  end
end

