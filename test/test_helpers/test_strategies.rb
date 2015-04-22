module RemotelyExceptional::Test
  class BasicStrategy
    class << self
      attr_accessor :exception_class

      def ===(exception)
        matcher === exception
      end

      def matcher
        lambda { |ex| ex.is_a?(exception_class) }
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
