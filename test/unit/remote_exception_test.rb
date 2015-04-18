require "test_helper"
require "remotely_exceptional/remote_exception"

module RemotelyExceptional
  class RemoteExceptionTest < RemotelyExceptional::TestCase
    Subject = RemoteException

    context Subject.name do
      subject { Subject }

      context "instance" do
        subject { Subject.new(@options ||= {}) }

        context "options" do
          [
            :context,
            :exception,
          ].each do |option|
            should "take a/an #{option} option" do
              expected_value = :expected_value
              @options = { option => expected_value }
              assert_equal expected_value, subject.send(option)
            end
          end
        end
      end
    end
  end
end
