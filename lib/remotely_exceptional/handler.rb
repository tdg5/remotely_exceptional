# Mixin providing basic functionality required for handling exceptions.
module RemotelyExceptional
  # Module used to identify those objects that can be used as a
  # RemotelyExceptional::Handler.
  module Handler
  end

  # Module used to namespace those objects that are provided by
  # RemotelyExceptional that can be used as a RemotelyExceptional::Handler.
  module Handlers
  end
end
