require "test_helper"
require "remotely_exceptional/matcher/delegate_matcher"

module RemotelyExceptional::Matcher
  class DelegateMatcherTest < RemotelyExceptional::TestCase
    Subject = RemotelyExceptional::Matcher::DelegateMatcher

    class TestIncluder
      include Subject
    end

    context Subject.name do
      subject { Subject }

      context "::new" do
        let(:generated_module) { subject.new }
        let(:matcher) { lambda { |ex| ArgumentError === ex } }

        should "generate a new Module" do
          assert_kind_of Module, generated_module
          assert_equal true, generated_module.ancestors.include?(subject)
        end

        should "include DelegateMatcher behavior in the generated module" do
          assert_equal true, generated_module.respond_to?(:matcher_delegate)
          assert_equal true, generated_module.respond_to?(:matcher_delegate=)
          assert_equal true, generated_module.respond_to?(:===)
        end

        should "set the generated modules matcher_delegate" do
          matcher_module = subject.new(matcher)
          assert_equal matcher, matcher_module.matcher_delegate
        end

        should "yield the module to a given block after it has been set up" do
          includes_delegate_matcher = has_matcher_delegate_set = false
          closure_subject, closure_matcher = subject, matcher
          subject.new(matcher) do
            includes_delegate_matcher = ancestors.include?(closure_subject)
            has_matcher_delegate_set = self.matcher_delegate == closure_matcher
          end
          assert_equal true, includes_delegate_matcher
          assert_equal true, has_matcher_delegate_set
        end
      end
    end

    context "class that includes #{Subject.name}" do
      subject { TestIncluder }

      setup do
        subject.instance_eval { self.matcher_delegate = nil }
      end

      should "be a RemotelyExceptional::Matcher" do
        assert_kind_of RemotelyExceptional::Matcher, subject.new
      end

      context "::===" do
        let(:method_name) { :=== }

        should "be responded to" do
          assert_equal true, subject.respond_to?(method_name)
        end

        should "call matcher_delegate#=== with all arguments" do
          args = [
            ex = ArgumentError.new,
          ]
          (faux_matcher = mock).expects(:===).with(*args)
          subject.expects(:matcher_delegate).returns(faux_matcher)
          subject === ex
        end

        should "match when expected to" do
          subject.matcher_delegate = lambda do |ex|
            ArgumentError === ex
          end

          assert_equal true, subject === ArgumentError.new
        end
      end

      context "::matcher_delegate" do
        let(:method_name) { :matcher_delegate }

        should "be responded to" do
          assert_equal true, subject.respond_to?(method_name)
        end

        should "return nil if no matcher_delegate has been set" do
          assert_nil subject.matcher_delegate
        end

        should "return the matcher_delegate, if set" do
          matcher = :Matcher
          subject.matcher_delegate = matcher
          assert_equal matcher, subject.matcher_delegate
        end
      end

      context "::matcher_delegate=" do
        let(:method_name) { :matcher_delegate= }

        should "be responded to" do
          assert_equal true, subject.respond_to?(:matcher_delegate=)
        end

        should "set the includer's ::matcher_delegate" do
          matcher = :Matcher
          subject.matcher_delegate = matcher
          assert_equal matcher, subject.matcher_delegate
        end
      end

      context "::new" do
        should "not be overriden" do
          instance = subject.new
          assert_kind_of subject, instance
          assert_kind_of Subject, instance
        end
      end
    end
  end
end
