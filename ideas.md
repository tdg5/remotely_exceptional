begin
  raise "Ahh!"
rescue Handler
end

with_remote_handler(SomeHandler) do
  raise "Ahh!"
end

def with_remote_handler(handler_class)
  yield
rescue handler_class
  response = handler_class.handle
  case response
  when :raise then raise
  when :redo then redo
  when :retry then retry
  when :continue then nil
  else
    raise InvalidHandlerResponse, "Handler did not return an expected response code!"
  end
end
