require "test_helper"
require "test_helpers/test_handlers"
require "remotely_exceptional/exception_contexts/continue_raise_retry"

module RemotelyExceptional::ExceptionContexts
  class ContinueRaiseRetryTest < RemotelyExceptional::TestCase
    Subject = ContinueRaiseRetry

    TestHandler = RemotelyExceptional::Test::BasicExceptionHandler

    context Subject.name do
      subject { Subject }

      context "#context_exec" do
        setup do
          @handler = TestHandler
          @instance = TestHandler.new
          @handler.stubs(:new).returns(@instance)
        end

        should "raise ArgumentError unless a block is given" do
          assert_raises(ArgumentError) { subject.context_exec(@handler) }
        end

        should "raise ArgumentError unless a Handler is given" do
          [nil, Class.new, Module.new, :not_a_handler].each do |handler|
            assert_raises(ArgumentError) { subject.context_exec(handler) { } }
          end
        end

        should "yield to the provided block" do
          block_called = false
          subject.context_exec(@handler) do
            block_called = true
          end
          assert_equal true, block_called
        end

        context "response codes" do
          should "raise InvalidHandlerResponse if unrecognized response code" do
            @instance.expects(:handle).returns(:not_a_thing)
            exception = assert_raises(RemotelyExceptional::InvalidHandlerResponse) do
              subject.context_exec(@handler) do
                raise @handler.exception_class
              end
            end
            assert_kind_of @handler.exception_class, exception.original_exception
          end

          should "retry if retry code is given" do
            @instance.expects(:handle).returns(:retry)
            already_called = false
            retried = false
            subject.context_exec(@handler) do
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
              subject.context_exec(@handler) do
                raise @handler.exception_class
              end
            end
          end

          should "raise given exception if raise code is given with exception" do
            exception_class = ArgumentError
            @instance.expects(:handle).returns([:raise, exception_class])
            assert_raises(exception_class) do
              subject.context_exec(@handler) do
                raise @handler.exception_class
              end
            end
          end

          should "continue if continue code is given" do
            @instance.expects(:handle).returns(:continue)
            result = subject.context_exec(@handler) do
              raise @handler.exception_class
            end
            assert_nil result
          end

          should "continue and return given value if continue code is given with value" do
            expected_result = 42
            @instance.expects(:handle).returns([:continue, expected_result])
            result = subject.context_exec(@handler) do
              raise @handler.exception_class
            end
            assert_equal expected_result, result
          end
        end
      end

      context "" do
        should "" do
        end
      end
    end
  end
end
