require "test_helper"

class RemotelyExceptionalTest < RemotelyExceptional::TestCase
  Subject = RemotelyExceptional

  [
    Subject,
  ].each do |mod|
    context mod.name do
      subject { mod }

      should "be defined" do
        assert_kind_of Module, subject
      end
    end
  end
end
