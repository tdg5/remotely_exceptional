require "test_helper"
require "test_helpers/test_strategies"

class RemotelyExceptional::RemoteHandlingTest < RemotelyExceptional::TestCase
  Subject = RemotelyExceptional::RemoteHandling

  TestStrategy = RemotelyExceptional::Test::BasicStrategy
  class TestMixer
    include Subject
  end

  context "class that includes #{Subject.name}" do
    context "instance" do
      subject { TestMixer.new }

      context "#remotely_exceptional" do
        should "delegate call to ExceptionContext.execute" do
          exception_context = RemotelyExceptional::ExceptionContext
          exception_context.expects(:execute).with(TestStrategy)
          subject.remotely_exceptional(TestStrategy) { }
        end
      end
    end
  end
end
