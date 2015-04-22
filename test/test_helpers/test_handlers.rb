module RemotelyExceptional::Test
  class BasicExceptionHandler
    class << self
      attr_accessor :exception_class

      def ===(exception)
        (lambda { |ex| ex.is_a?(exception_class) }) === exception
      end

      def handle(*args)
        new(*args).handle
      end
    end
    self.exception_class = RuntimeError

    def handle(*)
    end

    def report_retry_success(*)
    end
  end
end
