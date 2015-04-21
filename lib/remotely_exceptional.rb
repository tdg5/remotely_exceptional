require "remotely_exceptional/version"
require "remotely_exceptional/exception_context"
require "remotely_exceptional/remote_exception"
require "remotely_exceptional/remote_handling"

# The namespace for the RemotelyExceptional gem.
module RemotelyExceptional
  # Module used to identify and namespace those objects that can be used as a
  # RemotelyExceptional::Handler.
  module Handler
  end

  # Module used to identify and namespace those objects that can be used as a
  # RemotelyExceptional::Matcher.
  module Matcher
  end
end
