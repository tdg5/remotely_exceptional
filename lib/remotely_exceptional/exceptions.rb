module RemotelyExceptional
  class Error < ::RuntimeError
  end

  class InvalidHandlerResponse < RemotelyExceptional::Error
    attr_accessor :original_exception
    def initialize(*)
      super
      @original_exception = $!
    end
  end
end
