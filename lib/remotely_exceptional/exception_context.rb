module RemotelyExceptional
  # An ExceptionContext is a template code block that allows for executing code
  # with remote exception handling.
  module ExceptionContext
    # Execute the given code block within a special context that allows for
    # remote handling of exceptions.
    #
    # @param handler [Object] A handler object that responds to :=== and
    #   :handle.
    # @param context [Hash] A Hash of contextual information that is made
    #   available to the exception handler.
    def self.execute(handler, context = {})
      raise ArgumentError, "Block required!" unless block_given?

      remote_exception = nil
      report_retry_success = false

      # Must explicitly use begin otherwise TypeError will occur if handler is not
      # a Class or Module. We can raise a more specific error if begin is used.
      begin
        result = yield
        handler.report_retry_success(remote_exception) if report_retry_success
        result
      rescue handler => ex
        remote_exception = RemoteException.new({
          :context => context,
          :exception => ex,
        })
        # Yield the exception to the handler so it can determine the appropriate
        # action to take. Then act.
        handler.handle(remote_exception)
        case remote_exception.action
          when :continue then remote_exception.continue_value
          when :retry
            report_retry_success = handler.respond_to?(:report_retry_success)
            retry
          when :raise then raise remote_exception.raise_exception || ex
          else raise
        end
      end
    end
  end
end
