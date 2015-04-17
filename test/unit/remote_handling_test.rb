require "test_helper"
require "test_helpers/test_handlers"

class RemotelyExceptional::RemoteHandlingTest < RemotelyExceptional::TestCase
  Subject = RemotelyExceptional::RemoteHandling

  TestHandler = RemotelyExceptional::Test::BasicExceptionHandler
  class TestMixer
    include Subject
  end

  context "class that includes #{Subject.name}" do
    context "instance" do
      subject { TestMixer.new }

      context "#remotely_exceptional" do
        should "delegate call to ContinueRaiseRetry.context_exec" do
          exception_context = RemotelyExceptional::ExceptionContexts::ContinueRaiseRetry
          exception_context.expects(:context_exec).with(TestHandler)
          subject.remotely_exceptional(TestHandler) { }
        end
      end
    end
  end
end
