require "test_helper"
require "remotely_exceptional/handlers/prioritized_handler"

class RemotelyExceptional::Handlers::PrioritizedHandlerTest < RemotelyExceptional::TestCase
  Subject = RemotelyExceptional::Handlers::PrioritizedHandler

  AlphaHandler = RemotelyExceptional::Handler.new { |ex| !!ex }
  BetaHandler = RemotelyExceptional::Handler.new { |ex| !!ex }
  OmegaHandler = RemotelyExceptional::Handler.new { |ex| !!ex }

  class TestSubject < Subject
  end

  context Subject.name do
    subject { Subject }

    setup { subject.clear_handlers }

    context "::default_priority" do
      should "return 1000" do
        assert_equal 1000, subject.default_priority
      end
    end

    context "::prioritized_handlers" do
      setup do
        assert_equal true, subject.register_handler(AlphaHandler, :priority => 500)
        assert_equal true, subject.register_handler(OmegaHandler, :priority => 500)
        assert_equal true, subject.register_handler(BetaHandler, :priority => 500)
        assert_equal true, subject.register_handler(AlphaHandler)
        assert_equal true, subject.register_handler(OmegaHandler, :priority => 50)
      end

      should "yield handlers in priority ASC, name ASC order" do
        expected_handlers =  [
          OmegaHandler,
          AlphaHandler,
          BetaHandler,
          OmegaHandler,
          AlphaHandler,
        ]
        assert_equal expected_handlers, subject.prioritized_handlers.to_a
      end

      should "yield temporary handlers" do
      end
    end

    context "::register_handler" do
      should "return false if the handler was not registered" do
      end

      should "return true if the handler was registered" do
      end

      should "register the handler with the provided priority" do
      end

      should "register the handler with the default priority if no priority given" do
      end
    end

    context "::remove_handler" do
      should "return false if the handler was not removed" do
      end

      should "return true if the handler was removed" do
      end

      should "remove a handler with a matching priority" do
      end

      should "not remove a handler with a non-matching priority" do
      end
    end

    context "::with_handler" do
      should "raise ArgumentError if no block is given" do
      end

      should "register the handler if it is not already registered" do
      end

      should "register the handler with the given priority" do
      end

      should "register the handler with the default priority if no priority given" do
      end

      should "remove the handler after yielding" do
      end

      should "remove the handler even if an error occurs" do
      end
    end

  end
end
