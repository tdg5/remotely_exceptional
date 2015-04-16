require "test_helper"
require "remotely_exceptional/handlers/instance_handler"

module RemotelyExceptional::Handlers
  class InstanceHandlerTest < RemotelyExceptional::TestCase
    Subject = InstanceHandler

    class TestMixer
      include Subject
    end

    context Subject.name do
      subject { Subject }

      context "::new" do
        should "return a new class that includes #{Subject.name}" do
          test_class = subject.new {|other| true }
          assert_equal true, test_class.ancestors.include?(subject)
          assert_kind_of subject, test_class.new
        end

        should "take an optional super_class argument" do
          test_super_class = Class.new
          test_class = subject.new(test_super_class) {|other| true }
          assert_kind_of test_super_class, test_class.new
        end

        should "yield the generated class to a given block" do
          has_delegate_matcher_behavior = has_handler_behavior = false
          subject.new do
            has_delegate_matcher_behavior = respond_to?(:matcher_delegate)
            has_handler_behavior = respond_to?(:handle)
          end
          assert_equal true, has_delegate_matcher_behavior
          assert_equal true, has_handler_behavior
        end
      end
    end

    context TestMixer.name do
      subject { TestMixer }

      context "included behaviors" do
        context "::new" do
          should "not be overriden by the module" do
            assert_kind_of subject, subject.new
          end
        end

        context "::===" do
          should "call delegate_matcher#=== with the given argument" do
            expected_argument = ArgumentError
            (matcher = mock).expects(:===).with(expected_argument).returns(true)
            subject.expects(:matcher_delegate).returns(matcher)
            assert_equal true, subject === expected_argument
          end
        end

        context "::handle" do
          setup do
            @exception = ArgumentError.new
            @context = { :context => true }
            @instance = subject.new
            subject.expects(:new).at_least(1).returns(@instance)
          end

          should "create a new instance and invoke #handle" do
            @instance.expects(:handle)
            subject.handle(@exception, @context)
          end

          should "set the exception and context of the instance correctly" do
            @instance.stubs(:handle)
            subject.handle(@exception, @context)
            assert_equal @exception, @instance.exception
            assert_equal @context, @instance.context
          end

          should "should automatically detect exception if not provided in an exception context" do
            @instance.stubs(:handle)
            begin
              raise @exception
            rescue
              subject.handle(@context)
            end
            # Should be the exception in an exception context
            assert_equal @context, @instance.context
            assert_equal @exception, @instance.exception
          end

          should "have a nil exception when not provided an exception outside of an exception context" do
            @instance.stubs(:handle)
            subject.handle(@context)
            assert_equal @context, @instance.context
            # Should be nil outside of an exception context
            assert_nil @instance.exception
          end
        end

        context "rescue" do
          should "call the matcher_delegate with an exception class when used to rescue" do
            expected_argument = ArgumentError
            matcher = lambda { |other| !other.is_a?(expected_argument) }
            subject.expects(:matcher_delegate).returns(matcher)

            rescued = false
            assert_raises(ArgumentError) do
              begin
                raise ArgumentError
              rescue subject
                rescued = true
              end
            end
            assert_equal false, rescued
          end

          should "invoke rescue code when the matcher matches the exception" do
            expected_argument = ArgumentError
            matcher = lambda { |other| other.is_a?(expected_argument) }
            subject.expects(:matcher_delegate).returns(matcher)

            rescued = false
            begin
              raise ArgumentError
            rescue subject
              rescued = true
            end
            assert_equal true, rescued
          end
        end

        context "#handle" do
          should "raise NotImplementedError if not overriden" do
            assert_raises(NotImplementedError) { subject.new.handle }
          end
        end
      end
    end
  end
end
