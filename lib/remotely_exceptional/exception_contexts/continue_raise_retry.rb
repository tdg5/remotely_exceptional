module RemotelyExceptional::ExceptionContexts
  module ContinueRaiseRetry
    def self.context_exec(handler, context = {})
      raise ArgumentError, "Block required!" unless block_given?
      raise ArgumentError, "Invalid Handler! Got #{handler.inspect}" unless handler &&
        handler.respond_to?(:ancestors) &&
        handler.ancestors.include?(RemotelyExceptional::Handler)

      # Must explicitly use begin otherwise TypeError will occur if handler is not
      # a Class or Module. We can raise a more specific error if begin is used.
      begin
        yield
      rescue handler => ex
        remote = Remote.new
        remote_exception = RemoteException.new({
          :context => context,
          :exception => ex,
          :handler => handler,
          :remote => remote,
        })

        handler.handle(remote_exception)
        result = remote.result
        case result.action
          when :continue then result
          when :raise then result ? raise(result) : raise
          when :retry then retry
        end
      end
    end

    class Remote < RemotelyExceptional::Remote
    end
  end
end
