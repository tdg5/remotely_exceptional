require "test_helper"
require "test_helpers/test_strategies"
require "remotely_exceptional/exception_context"

module RemotelyExceptional
  class ExceptionContextTest < RemotelyExceptional::TestCase
    Subject = ExceptionContext

    TestStrategy = Test::BasicStrategy

    context Subject.name do
      subject { Subject }

      context "#execute" do
        setup do
          @strategy_class = TestStrategy
          @strategy = @strategy_class.new
          @strategy_class.stubs(:new).returns(@strategy)
          @remote_exception_class = RemotelyExceptional::RemoteException
          @remote_exception = @remote_exception_class.new
          @remote_exception_class.stubs(:new).returns(@remote_exception)
        end

        should "raise ArgumentError unless a block is given" do
          assert_raises(ArgumentError) { subject.execute(@strategy) }
        end

        should "yield to the provided block" do
          block_called = false
          subject.execute(@strategy_class) do
            block_called = true
          end
          assert_equal true, block_called
        end

        context "response codes" do
          should "retry if retry code is given" do
            @remote_exception.expects(:action).returns(:retry)

            retried = false
            subject.execute(@strategy_class) do
              if !retried
                retried = true
                raise @strategy_class.exception_class
              end
            end
            assert_equal true, retried
          end

          should "raise if unrecognized response code" do
            @remote_exception.expects(:action).returns(:not_a_thing)
            exception = assert_raises(@strategy_class.exception_class) do
              subject.execute(@strategy_class) do
                raise @strategy_class.exception_class
              end
            end
            assert_kind_of @strategy_class.exception_class, exception
          end

          should "raise original exception if raise code is given" do
            @remote_exception.expects(:action).returns(:raise)
            original_exception = nil
            exception = assert_raises(@strategy_class.exception_class) do
              subject.execute(@strategy_class) do
                original_exception = @strategy_class.exception_class.new
                raise original_exception
              end
            end
            assert_equal original_exception, exception
          end

          should "raise given exception if raise code is given with raise_exception set" do
            exception = ArgumentError.new
            @remote_exception.expects(:action).returns(:raise)
            @remote_exception.expects(:raise_exception).returns(exception)
            assert_raises(exception.class) do
              subject.execute(@strategy_class) do
                raise @strategy_class.exception_class
              end
            end
          end

          should "continue if continue code is given" do
            @remote_exception.expects(:action).returns(:continue)
            result = subject.execute(@strategy_class) do
              raise @strategy_class.exception_class
            end
            assert_nil result
          end

          should "continue and return given value if continue code is given with value" do
            expected_result = 42
            @remote_exception.expects(:action).returns(:continue)
            @remote_exception.expects(:continue_value).returns(expected_result)
            result = subject.execute(@strategy_class) do
              raise @strategy_class.exception_class
            end
            assert_equal expected_result, result
          end
        end

        should "report retry success to strategy if retry succeeds" do
          @remote_exception.expects(:action).returns(:retry)

          retried = false
          @strategy_class.expects(:report_retry_success).with(@remote_exception)
          subject.execute(@strategy_class) do
            if !retried
              retried = true
              raise @strategy_class.exception_class
            end
          end
          assert_equal true, retried
        end

        should "not report retry success to strategy that does not support it" do
          retried = false
          @strategy_class.expects(:respond_to?).with(:report_retry_success).returns(false)
          @strategy_class.expects(:report_retry_success).never
          subject.execute(@strategy_class) do
            if retried
              @remote_exception.expects(:action).returns(:continue)
            else
              @remote_exception.expects(:action).returns(:retry)
              retried = true
            end
            raise @strategy_class.exception_class
          end
          assert_equal true, retried
        end

        should "not report retry success to strategy if retry fails and other action taken" do
          retried = false
          @strategy_class.expects(:report_retry_success).never
          subject.execute(@strategy_class) do
            if retried
              @remote_exception.expects(:action).returns(:continue)
            else
              @remote_exception.expects(:action).returns(:retry)
              retried = true
            end
            raise @strategy_class.exception_class
          end
          assert_equal true, retried
        end
      end
    end
  end
end
