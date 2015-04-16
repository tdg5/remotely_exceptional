require "test_helper"

class RemotelyExceptional::HandlerTest < RemotelyExceptional::TestCase
  [
    RemotelyExceptional::Handler,
    RemotelyExceptional::Handlers,
  ].each do |mod|
    context mod.name do
      subject { mod }

      should "be defined" do
        assert_kind_of Module, subject
      end
    end
  end
end
