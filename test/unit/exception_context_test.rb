require "test_helper"

class RemotelyExceptional::ExceptionContextTest < RemotelyExceptional::TestCase
  [
    RemotelyExceptional::ExceptionContext,
    RemotelyExceptional::ExceptionContexts,
  ].each do |mod|
    context mod.name do
      subject { mod }

      should "be defined" do
        assert_kind_of Module, subject
      end
    end
  end
end
