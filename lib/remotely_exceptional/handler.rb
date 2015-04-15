# Mixin providing basic functionality required for matching and handling
# exceptions.
module RemotelyExceptional::Handler
  # Actions that will be taken on any object that includes this module.
  #
  # @param includer [Class,Module] The class or module that has included this
  #   module.
  def self.included(includer)
    includer.extend(ClassMethods)
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
  def self.new(super_class = Object, &block)
    raise ArgumentError, "Block required" unless block_given?
    handler_class = Class.new(super_class)
    handler_class.send(:include, self)
    handler_class.instance_variable_set(:@matcher, block)
    handler_class
  end

  # Class-level handler behaviors that will be added to any object that includes
  # this module.
  module ClassMethods
    # Used by Ruby's rescue keyword to evaluate if an exception instance can be
    # caught by this Class or Module. Delegates to {#matcher}.
    #
    # @param exception [Exception] The exception instance that should be evaluated
    #   for a match.
    # @return [Boolean] Returns a Boolean value indicating whether or not the
    #   exception instance matches this handler.
    def ===(exception)
      matcher.call(exception)
    end

    # Factory method that takes in an exception and an optional Hash of
    # additional contextual information and creates a new Handler instance from
    # that data. The generated Handler instance is then used to handle the the
    # exception.
    #
    # @param exception [Exception] The exception to handle. Defaults to $!.
    # @param context [Hash{Symbol=>Object}] An optional Hash of additional
    #   contextual information about the exception.
    # @return [Symbol] Returns a symbol indicating what action should be taken
    #   to continue execution. Depending on the situation, valid values include:
    #   [:continue, :raise, :retry]
    def handle(exception = $!, context = {})
      instance = new
      context, exception = exception, $! if exception.is_a?(Hash)
      instance.instance_variable_set(:@exception, exception)
      instance.instance_variable_set(:@context, context)
      instance.handle
    end

    private

    # The block used by the class to evaluate matching exceptions.
    def matcher
      @matcher
    end
  end

  attr_reader :context, :exception

  # Placeholder method, must be implemented by including class. Should
  # encapsulate the logic required to handle an exception matced by the class.
  # Should take no arguments.
  #
  # @raise [NotImplementedError] Raised when the including class does not
  #   provide it's own #handle instance method.
  # @return [Symbol] Returns a symbol indicating what action should be taken
  #   to continue execution. Depending on the situation, valid values include:
  #   [:continue, :raise, :retry]
  # @return [Array<(Symbol, Object)>] Returns a symbol indicating what action
  #   should be taken to continue execution and an object that should be used as
  #   the result of the rescue operation. Depending on the situation, valid
  #   action values include: [:continue, :raise, :retry]
  def handle
    raise NotImplementedError, "#{__method__} must be implemented by including class!"
  end
end
