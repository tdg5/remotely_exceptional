require "test_helper"
require "remotely_exceptional/remote_exception"

module RemotelyExceptional
  class RemoteExceptionTest < RemotelyExceptional::TestCase
    Subject = RemoteException

    context Subject.name do
      subject { Subject }

      context "instance" do
        subject { Subject.new(@options ||= {}) }

        context "#initialize" do
          context "options" do
            [
              :context,
              :exception,
            ].each do |option|
              should "take a/an #{option} option" do
                expected_value = :expected_value
                @options = { option => expected_value }
                assert_equal expected_value, subject.send(option)
              end
            end
          end
        end

        context "#action?" do
          should "return true if an action is set" do
            assert_equal !!subject.action, subject.action?
          end

          should "return false if an action is not set" do
            subject.instance_variable_set(:@action, :raise)
            assert_equal !!subject.action, subject.action?
          end
        end

        context "#available_actions" do
          should "return the expected values" do
            expected_actions = [:continue, :raise, :retry]
            assert_equal expected_actions, subject.available_actions
          end
        end

        context "#continue" do
          should "set the continue_value to the given value" do
            expected_result = :expected_value
            subject.continue(expected_result)
            assert_equal expected_result, subject.continue_value
          end

          should "set the continue_value to nil if no value given" do
            subject.continue
            assert_nil subject.continue_value
          end

          should "set the raise_exception to nil" do
            # Call raise to set the raise_exception
            subject.raise(ArgumentError)
            subject.continue
            assert_nil subject.raise_exception
          end

          should "set the action to :continue" do
            assert_equal false, subject.action?
            subject.continue
            assert_equal :continue, subject.action
          end
        end

        context "raise" do
          should "set the raise_exception to the given value" do
            expected_result = ArgumentError.new
            subject.raise(expected_result)
            assert_equal expected_result, subject.raise_exception
          end

          should "set the raise_exception to exception if no value given" do
            @options = { :exception => ArgumentError.new }
            subject.raise
            assert_equal @options[:exception], subject.raise_exception
          end

          should "set the continue_value to nil" do
            subject.continue(:some_value)
            subject.raise
            assert_nil subject.continue_value
          end

          should "set the action to :raise" do
            assert_equal false, subject.action?
            subject.raise
            assert_equal :raise, subject.action
          end
        end

        context "retry" do
          should "set the raise_exception to nil" do
            # Call raise to set the raise_exception
            subject.raise(ArgumentError)
            subject.retry
            assert_nil subject.raise_exception
          end

          should "set the continue_value to nil" do
            # Call continue to set the continue_value
            subject.continue(:some_value)
            subject.raise
            assert_nil subject.continue_value
          end

          should "set the action to :retry" do
            assert_equal false, subject.action?
            subject.retry
            assert_equal :retry, subject.action
          end
        end
      end
    end
  end
end
