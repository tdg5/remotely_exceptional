require "test_helper"
require "remotely_exceptional/remote"

class RemotelyExceptional::RemoteTest < RemotelyExceptional::TestCase
  Subject = RemotelyExceptional::Remote

  context Subject.name do
    subject { Subject }

    context "" do
      should "" do
      end
    end
  end
end
