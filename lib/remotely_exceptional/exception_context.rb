module RemotelyExceptional
  # An ExceptionContext is a template code block that allows for executing code
  # with remote exception handling.
  module ExceptionContext
    # Execute the given code block within a special context that allows for
    # remote handling of exceptions.
    #
    # @param strategy [Object] A strategy object that responds to #===,
    #   #handle, and possibly #report_retry_success.
    # @param context [Hash] A Hash of contextual information that is made
    #   available to the exception handler.
    def self.execute(strategy, context = {})
      raise ArgumentError, "Block required!" unless block_given?

      remote_exception = nil

      # Must explicitly use begin otherwise TypeError will occur if strategy is not
      # a Class or Module. We can raise a more specific error if begin is used.
      begin
        result = yield
        if remote_exception && strategy.respond_to?(:report_retry_success)
          strategy.report_retry_success(remote_exception)
        end
        result
      rescue strategy => ex
        remote_exception = RemoteException.new({
          :context => context,
          :exception => ex,
        })
        # Yield the exception to the strategy so it can determine the appropriate
        # action to take. Then act.
        strategy.handle(remote_exception)
        case remote_exception.action
          when :continue
            remote_exception.continue_value
          when :retry
            retry
          when :raise
            raise(remote_exception.raise_exception || ex)
          else raise
        end
      end
    end
  end
end
