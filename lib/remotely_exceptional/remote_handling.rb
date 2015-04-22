module RemotelyExceptional::RemoteHandling
  def self.included(includer)
    includer.extend(ClassMethods)
  end

  def remotely_exceptional(*args, &block)
    self.class.remotely_exceptional(*args, &block)
  end

  module ClassMethods
    def remotely_exceptional(*args, &block)
      RemotelyExceptional::ExceptionContext.execute(*args, &block)
    end
  end
end
