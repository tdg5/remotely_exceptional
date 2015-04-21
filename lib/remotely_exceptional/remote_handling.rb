module RemotelyExceptional::RemoteHandling
  extend Forwardable
  def_delegator "RemotelyExceptional::ExceptionContext",
    :execute,
    :remotely_exceptional
end
