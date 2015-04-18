require "test_helper"
require "test_helpers/test_remote_exceptions"
require "remotely_exceptional/handler/instance_handler"
require "remotely_exceptional/handler/prioritized_handler"

class RemotelyExceptional::Handler::PrioritizedHandlerTest < RemotelyExceptional::TestCase
  Subject = RemotelyExceptional::Handler::PrioritizedHandler
  InstanceHandler = RemotelyExceptional::Handler::InstanceHandler
  AlphaHandler = InstanceHandler.new do
    self.matcher_delegate = lambda { |ex| ArgumentError === ex }

    def self.action
      :retry
    end

    def handle(remote_exception)
      remote_exception.send(self.class.action)
    end
  end
  BetaHandler = InstanceHandler.new do
    self.matcher_delegate = lambda { |ex| StandardError === ex }
  end
  OmegaHandler = InstanceHandler.new do
    self.matcher_delegate = lambda { |ex| Exception === ex }

    def self.action
      :raise
    end

    def handle(remote_exception)
      remote_exception.send(self.class.action)
    end
  end
  RemoteException = RemotelyExceptional::Test::BasicRemoteException

  class TestSubject
    include Subject
  end

  class TestRemote
    include RemotelyExceptional::RemoteHandling
  end

  context "module that includes #{Subject.name}" do
    subject { TestSubject }

    setup { subject.reset_handlers! }

    context "::===" do
      should "return true if a handler is registered that matches the exception" do
        subject.register_handler(AlphaHandler)
        assert_equal true, subject === ArgumentError.new
      end

      should "return false if none of the handlers match the exception" do
        subject.register_handler(AlphaHandler)
        assert_equal false, subject === RuntimeError.new
      end
    end

    context "::default_priority" do
      should "return 1000" do
        assert_equal 1000, subject.default_priority
      end
    end

    context "::handle" do
      should "delegate handling to matching handlers while no action is decided" do
        handler_sequence = sequence(:handler_order)
        subject.register_handler(AlphaHandler)
        subject.register_handler(OmegaHandler, :priority => 10)
        remote_exception = RemoteException.new(:exception => ArgumentError.new)
        OmegaHandler.expects(:handle).with(remote_exception).in_sequence(handler_sequence)
        AlphaHandler.expects(:handle).with(remote_exception).in_sequence(handler_sequence)
        subject.handle(remote_exception)
        # should leave action unchanged since handle does nothing in both cases
        assert_equal nil, remote_exception.action
      end

      should "should discontinue handling after an action has been decided" do
        subject.register_handler(AlphaHandler)
        subject.register_handler(OmegaHandler, :priority => 10)
        remote_exception = RemoteException.new(:exception => ArgumentError.new)
        AlphaHandler.expects(:handle).never
        subject.handle(remote_exception)
        assert_equal OmegaHandler.action, remote_exception.action
      end
    end

    context "::handlers_for_exception" do
      should "return all matching handlers" do
        subject.register_handler(AlphaHandler)
        subject.register_handler(OmegaHandler)
        expected_handlers = [AlphaHandler, OmegaHandler]
        result_handlers = subject.handlers_for_exception(ArgumentError.new)
        assert_equal expected_handlers, result_handlers
      end

      should "return the matching handlers in priority ASC, name ASC order" do
        subject.register_handler(BetaHandler)
        subject.register_handler(AlphaHandler)
        subject.register_handler(OmegaHandler, :priority => 10)
        result_handlers = subject.handlers_for_exception(ArgumentError.new)
        expected_handlers = [OmegaHandler, AlphaHandler, BetaHandler]
        assert_equal expected_handlers, result_handlers
      end

      should "return an empty Array if no matching handler is found" do
        subject.register_handler(AlphaHandler)
        subject.register_handler(BetaHandler)
        assert_equal [], subject.handlers_for_exception(SystemStackError.new)
      end
    end

    context "::prioritized_handlers" do
      should "yield handlers in priority ASC, name ASC order" do
        setup_registered_handlers(subject)
        found_handlers = nil
        # Should be yielded first
        subject.with_handler(BetaHandler, :priority => 5) do
          # Should be yielded last
          subject.with_handler(OmegaHandler, :priority => 2500) do
            # Should only be yielded once for this priority
            subject.with_handler(AlphaHandler) do
              found_handlers = subject.prioritized_handlers.to_a
            end
          end
        end
        @expected_handlers.unshift(BetaHandler)
        @expected_handlers.push(OmegaHandler)
        assert_equal @expected_handlers, found_handlers
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

      should "yield a handler only once per priority level" do
        subject.register_handler(AlphaHandler)
        found_handlers = nil
        subject.with_handler(AlphaHandler) do
          found_handlers = subject.prioritized_handlers.to_a
        end
        assert_equal 1, found_handlers.length
        assert_equal AlphaHandler, found_handlers.first
      end

      context "set scan" do
        should "not create empty sets when no keys exist" do
          subject.prioritized_handlers.to_a
          assert_empty subject.send(:registered_handlers)
          assert_empty subject.send(:block_handlers)
        end

        should "not create empty sets when a key exists in one set" do
          priority = 1000
          subject.with_handler(AlphaHandler, :priority => priority) do
            subject.prioritized_handlers.to_a
          end
          assert_equal false, subject.send(:registered_handlers).key?(priority)

          priority = 10
          subject.register_handler(AlphaHandler, :priority => priority)
          assert_equal false, subject.send(:block_handlers).key?(priority)
        end
      end
    end

    context "::register_handler" do
      should "return false if the handler was not registered" do
        priority = 10
        assert_equal true, subject.register_handler(AlphaHandler, :priority => priority)
        assert_equal false, subject.register_handler(AlphaHandler, :priority => priority)
      end

      should "return true if the handler was registered" do
        priority = 10
        assert_equal true, subject.register_handler(AlphaHandler, :priority => priority)
      end

      should "register the handler with the provided priority" do
        priority = 10
        registered_handlers = subject.send(:registered_handlers)
        registered_handlers.expects(:[]).with(priority).returns(Set.new)
        assert_equal true, subject.register_handler(AlphaHandler, :priority => priority)
      end

      should "register the handler with the default priority if no priority given" do
        priority = subject.default_priority
        registered_handlers = subject.send(:registered_handlers)
        registered_handlers.expects(:[]).with(priority).returns(Set.new)
        assert_equal true, subject.register_handler(AlphaHandler)
      end
    end

    context "::remove_handler" do
      should "return false if the handler was not removed" do
        assert_equal false, subject.remove_handler(AlphaHandler)
      end

      should "return true if the handler was removed" do
        assert_equal true, subject.register_handler(AlphaHandler)
        assert_equal true, subject.remove_handler(AlphaHandler)
      end

      should "remove a handler with a matching priority" do
        priority = 10
        assert_equal true, subject.register_handler(AlphaHandler, :priority => priority)
        assert_equal true, subject.remove_handler(AlphaHandler, :priority => priority)
      end

      should "not remove a handler with a non-matching priority" do
        priority = 10
        assert_equal true, subject.register_handler(AlphaHandler, :priority => priority)
        assert_equal false, subject.remove_handler(AlphaHandler)
      end
    end

    context "::reset_handlers!" do
      should "clear all handlers" do
        subject.register_handler(AlphaHandler, :priority => 10)
        initial_found_handlers = final_found_handlers = nil
        subject.with_handler(AlphaHandler) do
          initial_found_handlers = subject.prioritized_handlers.to_a
          subject.reset_handlers!
          final_found_handlers = subject.prioritized_handlers.to_a
        end
        assert_equal 2, initial_found_handlers.length
        assert_equal 0, final_found_handlers.length
      end
    end

    context "::with_handler" do
      should "raise ArgumentError if no block is given" do
        assert_raises(ArgumentError) do
          subject.with_handler(AlphaHandler)
        end
      end

      should "register the handler if it is not already registered" do
        assert_equal true, subject.prioritized_handlers.none?
        subject.with_handler(AlphaHandler) do
          found_handlers = subject.prioritized_handlers.to_a
          assert_equal 1, found_handlers.length
          assert_equal AlphaHandler, subject.prioritized_handlers.first

          # Should not add the handler again.
          subject.with_handler(AlphaHandler) do
            found_handlers = subject.prioritized_handlers.to_a
            assert_equal 1, found_handlers.length
            assert_equal AlphaHandler, subject.prioritized_handlers.first
          end
        end
        assert_equal true, subject.prioritized_handlers.none?
      end

      should "register the handler with the given priority" do
        priority = 10
        assert_equal true, subject.prioritized_handlers.none?
        subject.with_handler(AlphaHandler, :priority => priority) do
          found_handler = subject.send(:block_handlers)[priority].first
          assert_equal AlphaHandler, found_handler
        end
        assert_equal true, subject.prioritized_handlers.none?
      end

      should "register the handler with the default priority if no priority given" do
        priority = subject.default_priority
        assert_equal true, subject.prioritized_handlers.none?
        subject.with_handler(AlphaHandler, :priority => priority) do
          found_handler = subject.send(:block_handlers)[priority].first
          assert_equal AlphaHandler, found_handler
        end
        assert_equal true, subject.prioritized_handlers.none?
      end

      should "remove the handler after yielding" do
        assert_equal true, subject.prioritized_handlers.none?
        subject.with_handler(AlphaHandler) do
          assert_equal AlphaHandler, subject.prioritized_handlers.first
        end
        assert_equal true, subject.prioritized_handlers.none?
      end

      should "remove the handler even if an error occurs" do
        assert_equal true, subject.prioritized_handlers.none?
        assert_raises(Exception) do
          subject.with_handler(AlphaHandler) do
            assert_equal AlphaHandler, subject.prioritized_handlers.first
            raise Exception
          end
        end
        assert_equal true, subject.prioritized_handlers.none?
      end
    end

    context "behavior as a Handler" do
      should "be a valid Handler" do
        subject.register_handler(AlphaHandler, :priority => 10)
        remote = TestRemote.new
        block_called = false
        remote.remotely_exceptional(subject) { block_called = true }
        assert_equal true, block_called
      end
    end

    context "instance" do
      context "#handle" do
        should "not be defined" do
          instance = subject.new
          assert_equal false, instance.respond_to?(:handle)
        end
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
