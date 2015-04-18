require "remotely_exceptional/matcher/delegate_matcher"
require "remotely_exceptional/handler/instance_handler"

module RemotelyExceptional::Test
  class BasicExceptionHandler
    include RemotelyExceptional::Matcher::DelegateMatcher
    include RemotelyExceptional::Handler::InstanceHandler

    class << self
      attr_accessor :exception_class

      def matcher_delegate
        lambda { |ex| ex.is_a?(exception_class) }
      end
    end
    self.exception_class = RuntimeError

    def handle(*)
    end
  end
end
