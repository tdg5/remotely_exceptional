require "remotely_exceptional/matcher/delegate_matcher"

# Mixin providing basic functionality required for matching and handling
# exceptions where exceptions are handled using instances of the class.
module RemotelyExceptional::Handler::InstanceHandler
  include RemotelyExceptional::Matcher::DelegateMatcher
  include RemotelyExceptional::Handler

  # Actions that will be taken on any object that includes this module.
  #
  # @param includer [Class,Module] The class or module that has included this
  #   module.
  def self.included(includer)
    includer.instance_eval do
      include RemotelyExceptional::Handler
      include RemotelyExceptional::Matcher::DelegateMatcher
      extend ClassMethods
    end
  end

  # Factory function for creating classes with Handler behaviors. Creates a new
  # class with Handler behaviors from the given super class and block. By
  # default the super class of the new class will be Object. The given block
  # will be used as the matcher of the generated class.
  #
  # @param super_class [Class] An optional super class to use when creating a
  #   new class with Handler behaviors.
  # @yieldparam [Exception] exception_instance The exception instance that
  #   should be evaluated for a match.
  # @yieldreturn [Boolean] A boolean value indicating whether or not the
  #   exception instance was matched.
  # @return [Class] Returns a new class extended with Handler behaviors.
  def self.new(super_class = Object, &init_block)
    handler_class = Class.new(super_class)
    handler_class.send(:include, self)
    handler_class.class_eval(&init_block) if block_given?
    handler_class
  end

  # Class-level handler behaviors that will be added to any object that includes
  # this module.
  module ClassMethods
    # Factory method that takes in a remote exception and creates a new Handler
    # instance from that exception. The generated Handler instance is then used to
    # handle the the exception.
    #
    # @param remote_exception [RemotelyExceptional::RemoteException] The
    #   remote exception to handle.
    # @return [void]
    def handle(remote_exception)
      new.handle(remote_exception)
      nil
    end
  end

  # Placeholder method, must be implemented by including class. Should
  # encapsulate the logic required to handle a remote exception matced by the
  # class.
  #
  # @raise [NotImplementedError] Raised when the including class does not
  #   provide it's own #handle instance method.
  def handle(remote_exception)
    raise NotImplementedError, "#{__method__} must be implemented by including class!"
  end
end
