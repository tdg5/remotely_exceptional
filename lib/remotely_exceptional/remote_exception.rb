module RemotelyExceptional
  class RemoteException
    attr_reader :action, :context, :continue_value, :exception, :raise_exception

    def initialize(options = {})
      @context = options[:context]
      @exception = options[:exception]
    end

    def action?
      !!@action
    end

    def continue(continue_value = nil)
      @continue_value = continue_value
      @raise_exception = nil
      @action = :continue
    end

    def raise(raise_exception = nil)
      @continue_value = nil
      @raise_exception = raise_exception || exception
      @action = :raise
    end

    def retry
      @continue_value = nil
      @raise_exception = nil
      @action = :retry
    end
  end
end
