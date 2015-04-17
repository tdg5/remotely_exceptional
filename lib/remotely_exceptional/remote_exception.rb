module RemotelyExceptional
  class RemoteException
    attr_reader :context, :exception, :handler, :remote

    def initialize(options = {})
      @context = options[:context]
      @exception = options[:exception]
      @handler = options[:handler]
      @remote = options[:remote]
    end
  end
end
