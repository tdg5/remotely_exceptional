require "test_helper"
require "remotely_exceptional/remote_exception"

module RemotelyExceptional
  class RemoteExceptionTest < RemotelyExceptional::TestCase
    Subject = RemoteException

    context Subject.name do
      subject { Subject }

      context "" do
      end
    end
  end
end
