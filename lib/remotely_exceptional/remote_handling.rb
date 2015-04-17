require "remotely_exceptional/exception_contexts/continue_raise_retry"

module RemotelyExceptional::RemoteHandling
  extend Forwardable
  def_delegator "RemotelyExceptional::ExceptionContexts::ContinueRaiseRetry", :context_exec, :remotely_exceptional
end
