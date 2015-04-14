require "test_helper"

class RemotelyExceptional::ExceptionsTest < RemotelyExceptional::TestCase
  exception = RemotelyExceptional::InvalidHandlerResponse
  context exception.name do
    subject { exception }
    context "#original_exception" do
      should "capture the original exception if one exists" do
        assert_nil subject.new.original_exception
        exception = ArgumentError
        rescued = false
        begin
          raise exception
        rescue exception
          rescued = true
          assert_kind_of exception, subject.new.original_exception
        end
        assert_equal true, rescued
      end
    end
  end
end
