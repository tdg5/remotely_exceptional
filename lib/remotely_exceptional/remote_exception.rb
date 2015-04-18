module RemotelyExceptional
  class RemoteException
    attr_reader :context, :exception

    def initialize(options = {})
      @context = options[:context]
      @exception = options[:exception]
    end
  end
end
