require "test_helper"

class RemotelyExceptionalTest < RemotelyExceptional::TestCase
  Subject = RemotelyExceptional

  subject { Subject }

  context Subject.name do
    should "be defined" do
      assert defined?(subject), "Expected #{subject.name} to be defined!"
    end
  end
end
