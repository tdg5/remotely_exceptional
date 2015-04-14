module RemotelyExceptional::RemoteHandling
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
      when :raise
        result ? raise(result) : raise
      when :retry then retry
      when :continue then result
      else
        msg = "Handler did not return an expected response code!"
        raise RemotelyExceptional::InvalidHandlerResponse, msg
      end
    end
  end
end
