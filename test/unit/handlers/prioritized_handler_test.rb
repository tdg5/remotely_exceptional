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

    setup { subject.reset_handlers! }

    context "::default_priority" do
      should "return 1000" do
        assert_equal 1000, subject.default_priority
      end
    end

    context "::prioritized_handlers" do
      should "yield handlers in priority ASC, name ASC order" do
        setup_registered_handlers(subject)
        subject.with_handler(BetaHandler, :priority => 5) do
          subject.with_handler(OmegaHandler, :priority => 2500) do
            subject.with_handler(AlphaHandler) do
              found_handlers = subject.prioritized_handlers.to_a
            end
          end
        end
      end

      should "work when there are only registered handlers" do
        setup_registered_handlers(subject)
        subject.instance_variable_set(:@block_handlers, nil)
        assert_equal @expected_handlers, subject.prioritized_handlers.to_a
      end

      should "work when there are only block handlers" do
        found_handlers = nil
        subject.with_handler(BetaHandler, :priority => 5) do
          subject.with_handler(OmegaHandler, :priority => 2500) do
            subject.with_handler(AlphaHandler) do
              found_handlers = subject.prioritized_handlers.to_a
            end
          end
        end
        expected_handlers = [
          BetaHandler,
          AlphaHandler,
          OmegaHandler,
        ]
        assert_equal expected_handlers, found_handlers
      end

      context "not create empty handler sets during scan" do
        should "when no keys exist" do
          found_handlers = subject.prioritized_handlers.to_a
          
        end
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

  def setup_registered_handlers(handler)
    # 5
    assert_equal true, handler.register_handler(AlphaHandler)
    # 2
    assert_equal true, handler.register_handler(AlphaHandler, :priority => 500)
    # 3
    assert_equal true, handler.register_handler(BetaHandler, :priority => 500)
    # 1
    assert_equal true, handler.register_handler(OmegaHandler, :priority => 50)
    # 4
    assert_equal true, handler.register_handler(OmegaHandler, :priority => 500)

    @expected_handlers =  [
      OmegaHandler,
      AlphaHandler,
      BetaHandler,
      OmegaHandler,
      AlphaHandler,
    ]
  end
end
