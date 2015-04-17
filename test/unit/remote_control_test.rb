require "test_helper"
require "remotely_exceptional/remote_control"

class RemotelyExceptional::RemoteControlTest < RemotelyExceptional::TestCase
  Subject = RemotelyExceptional::RemoteControl

  context Subject.name do
    subject { Subject }

    context "" do
      should "" do
      end
    end
  end
end
