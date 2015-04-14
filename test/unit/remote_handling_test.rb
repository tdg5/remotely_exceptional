require "test_helper"

class RemotelyExceptional::RemoteHandlingTest < RemotelyExceptional::TestCase
  Subject = RemotelyExceptional::RemoteHandling

  class TestMixer
    include Subject
  end

  class TestHandler
    include RemotelyExceptional::Handler
    def self.matcher
      lambda { |ex| ex.is_a?(exception_class) }
    end

    def self.exception_class
      RuntimeError
    end
  end

  context Subject.name do
  end

  context "class that includes #{Subject.name}" do

    context "#remotely_exceptional" do
      subject { TestMixer.new }

      setup do
        @handler = TestHandler
        @instance = TestHandler.new
        @handler.stubs(:new).returns(@instance)
      end

      should "raise ArgumentError unless a Handler is given" do
        [nil, Class.new, Module.new, :not_a_handler].each do |handler|
          assert_raises(ArgumentError) { subject.remotely_exceptional(handler) }
        end
      end

      should "yield to the provided block" do
        block_called = false
        subject.remotely_exceptional(@handler) do
          block_called = true
        end
        assert_equal true, block_called
      end

      context "response codes" do
        should "raise InvalidHandlerResponse if unrecognized response code" do
          @instance.expects(:handle).returns(:not_a_thing)
          exception = assert_raises(RemotelyExceptional::InvalidHandlerResponse) do
            subject.remotely_exceptional(@handler) do
              raise @handler.exception_class
            end
          end
          assert_kind_of @handler.exception_class, exception.original_exception
        end

        should "retry if retry code is given" do
          @instance.expects(:handle).returns(:retry)
          already_called = false
          retried = false
          subject.remotely_exceptional(@handler) do
            if already_called
              retried = true
            else
              already_called = true
              raise @handler.exception_class
            end
          end
          assert_equal true, retried
        end

        should "raise if raise code is given" do
          @instance.expects(:handle).returns(:raise)
          assert_raises(@handler.exception_class) do
            subject.remotely_exceptional(@handler) do
              raise @handler.exception_class
            end
          end
        end

        should "raise given exception if raise code is given with exception" do
          exception_class = ArgumentError
          @instance.expects(:handle).returns([:raise, exception_class])
          assert_raises(exception_class) do
            subject.remotely_exceptional(@handler) do
              raise @handler.exception_class
            end
          end
        end

        should "continue if continue code is given" do
          @instance.expects(:handle).returns(:continue)
          result = subject.remotely_exceptional(@handler) do
            raise @handler.exception_class
          end
          assert_nil result
        end

        should "continue and return given value if continue code is given with value" do
          expected_result = 42
          @instance.expects(:handle).returns([:continue, expected_result])
          result = subject.remotely_exceptional(@handler) do
            raise @handler.exception_class
          end
          assert_equal expected_result, result
        end
      end
    end
  end
end
