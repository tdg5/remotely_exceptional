require "test_helper"

class RemotelyExceptional::MatcherTest < RemotelyExceptional::TestCase
  [
    RemotelyExceptional::Matcher,
    RemotelyExceptional::Matchers,
  ].each do |mod|
    context mod.name do
      subject { mod }

      should "be defined" do
        assert_kind_of Module, subject
      end
    end
  end
end
