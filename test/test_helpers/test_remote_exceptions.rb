require "remotely_exceptional/remote_exception"

module RemotelyExceptional::Test
  class BasicRemoteException < RemotelyExceptional::RemoteException
    attr_accessor :action, :continue_value, :raise_exception
  end
end
