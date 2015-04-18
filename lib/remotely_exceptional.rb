require "remotely_exceptional/version"
require "remotely_exceptional/remote_exception"
require "remotely_exceptional/remote_handling"

# The namespace for the RemotelyExceptional gem.
module RemotelyExceptional
  # Module used to identif and namespace those objects that can be used as a
  # RemotelyExceptional::ExceptionContext. An ExceptionContext is a template
  # code block that provides a template for executing code with certain kinds of
  # exception handling. Each ExceptionContext is specially
  # designed to handle specific kinds of exception situations. For example,
  # handling exceptions that utilize redo require a special exception context.
  module ExceptionContext
  end

  # Module used to identify and namespace those objects that can be used as a
  # RemotelyExceptional::Handler.
  module Handler
  end

  # Module used to identify and namespace those objects that can be used as a
  # RemotelyExceptional::Matcher.
  module Matcher
  end
end
