module RemotelyExceptional::RemoteHandling
  # Executes the given block of code in a context that allows for remote
  # handling of exceptions using the specified handler class. Optionally,
  # additional contextual information may be provided in case of an exception.
  #
  # @param handler [RemotelyExceptional::Handler] The handler that should be
  #   used to match and handle any exceptions that occur.
  # @param context [Hash{Symbol=>Object}] Optional contextual information that
  #   will be made available to the handler if an exception occurs.
  # @raise [ArgumentError] Raised if the provided handler is not a valid
  #   RemotelyExceptional::Handler.
  # @raise [RemotelyExceptional::InvalidHandlerResponse] Raised if an exception
  #   is raised but the handler does not return a valid action symbol.
  # @raise [Exception] Depending on the Handler used, could raise any error
  #   returned by the handler's handle method.
  # @return [Object] Returns the result of the given block if no exception
  #   occurs.
  # @return [Object, nil] If an exception occurs may return a result value
  #   provided by the exception handler's handle method. If the handler's handle
  #   method does not specify a result, nil will be returned instead.
  def remotely_exceptional(handler, context = {})
    raise ArgumentError, "Invalid Handler! Got #{handler.inspect}" unless handler &&
      handler.respond_to?(:ancestors) &&
      handler.ancestors.include?(RemotelyExceptional::Handler)

    # Must explicitly use begin otherwise TypeError will occur if handler is not
    # a Class or Module. We can raise a more specific error if begin is used.
    begin
      yield
    rescue handler
      response_code, result = handler.handle(context)
      case response_code
      when :raise then result ? raise(result) : raise
      when :retry then retry
      when :continue then result
      else
        msg = "Handler did not return an expected response code!"
        raise RemotelyExceptional::InvalidHandlerResponse, msg
      end
    end
  end
end
