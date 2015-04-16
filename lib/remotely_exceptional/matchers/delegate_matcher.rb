module RemotelyExceptional::Matchers
  # A mixin that adds Matcher behaviors that simply wrap another object. Calls
  # to determine equality are delegated to the wrapped object.
  module DelegateMatcher
    include RemotelyExceptional::Matcher

    # Adds behaviors to the Class or Module that includes this module.
    #
    # @param includer [Class, Module] The Class or Module to include
    #   BlockMatcher behavior in.
    # @return [void]
    def self.included(includer)
      includer.extend(ClassMethods)
      includer.singleton_class.instance_eval do
        attr_accessor :matcher_delegate
      end
    end

    # Factory function for creating modules with BlockMatcher behaviors. Creates
    # a new module with BlockMatcher behaviors where the given block will be
    # used to evaluate matches. Similar to Module::new, if a block is given, the
    # block will be evaluated on the generated module using module_eval after
    # the BlockMatcher behaviors have been added to the module.
    #
    # @param matcher [Object] The object that should be delegated to when ::===
    #   is invoked on the generated module.
    # @return [Module] Returns a new Module that includes Matcher behaviors.
    def self.new(matcher = nil, &init_block)
      # Closures, baby!
      delegate_matcher = self
      Module.new do
        include delegate_matcher
        @matcher_delegate = matcher
        module_eval(&init_block) if init_block
      end
    end

    module ClassMethods
      # Used by Ruby's rescue keyword to evaluate if an exception instance can be
      # caught by this Class or Module. Delegates to {#matcher_delegate}.
      #
      # @param exception [Exception] The exception instance that should be evaluated
      #   for a match.
      # @return [Boolean] Returns a Boolean value indicating whether or not the
      #   exception instance matches this handler.
      def ===(exception)
        matcher_delegate === exception
      end
    end
  end
end
