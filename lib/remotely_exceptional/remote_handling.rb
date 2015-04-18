require "remotely_exceptional/exception_context/continue_raise_retry"

module RemotelyExceptional::RemoteHandling
  extend Forwardable
  def_delegator "RemotelyExceptional::ExceptionContext::ContinueRaiseRetry",
    :context_exec,
    :remotely_exceptional
end
