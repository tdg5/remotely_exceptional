module RemotelyExceptional::Handler::PrioritizedHandler
  include RemotelyExceptional::Matcher
  include RemotelyExceptional::Handler

  # The default priority that should be used when registering handlers.
  DEFAULT_PRIORITY = 1000.freeze

  # Hash#default_proc for hashes that should return a new Set if a given key is
  # not defined.
  HASH_BUILDER = lambda { |hash, key| hash[key] = Set.new }.freeze

  def self.included(includer)
    includer.extend(ClassMethods)
  end

  module ClassMethods
    # Determines if any of the available handlers match the provided exception.
    #
    # @param exception [Exception] An exception.
    # @return [Boolean] Returns true if a handler is available that matches the
    #   given exception. Returns false if none of the available handlers match the
    #   given exception.
    def ===(exception)
      handlers_for_exception(exception).any?
    end

    # Returns the Hash of block handlers by priority.
    #
    # @return [Hash{Integer,Set}] The Hash of priorities and which block handlers
    #   belong to those priorities.
    def block_handlers
      Thread.current["#{name}.block_handlers"] ||= Hash.new(&HASH_BUILDER)
    end

    # The default priority level that should be used for handlers when no priority
    # is provided.
    #
    # @return [Integer] The default priority level.
    def default_priority
      const_get(:DEFAULT_PRIORITY)
    end

    # Finds all handlers that match the given remote exception and and attempts
    # to handle the exception trying one handler at a time in (priority ASC,
    # name ASC) order. Once an action has been decided for the given remote
    # exception, execution of additional handlers is short-circuited and no more
    # handlers will be executed.
    #
    # @param remote_exception [RemotelyExceptional::RemoteException] The
    #   remote exception to handle.
    # @return [void]
    def handle(remote_exception)
      handlers_for_exception(remote_exception.exception).each do |handler|
        handler.handle(remote_exception)
        break if remote_exception.action?
      end
    end

    # Returns all handlers that match the given exception in priority order.
    # exception. Returns an empty Array if no handlers were found.
    #
    # @param exception [Exception] The exception to find matching handlers for.
    # @return [Array<RemotelyExceptional::Handler>] Returns an Array of handlers
    #   that match the given exception in priority ASC, name ASC order. If no
    #   handlers are found, returns an empty Array.
    def handlers_for_exception(exception)
      prioritized_handlers.select { |handler| handler === exception }
    end

    # Returns an enumerator that yields block handlers and registered handlers in
    # priority ASC, name ASC order. The collection is lazily generated, so changes
    # to the sets of handlers may appear during traversal. If consistent state is
    # necessary, force the returned enumerator to eagerly generate the full
    # collection using #to_a or similar.
    #
    # @return [Enumerator<RemotelyExceptional::Handler>] An enumerator of all
    #   known block handlers and registered handlers in priority ASC, name ASC
    #   order.
    def prioritized_handlers
      Enumerator.new do |yielder|
        priorities = (registered_handlers.keys | block_handlers.keys).sort!
        priorities.uniq!
        priorities.each do |priority|
          if registered_handlers.key?(priority)
            collected_handlers = registered_handlers[priority].to_a
          end
          if block_handlers.key?(priority)
            temp_handlers = block_handlers[priority].to_a
            collected_handlers &&= collected_handlers.concat(temp_handlers)
            collected_handlers ||= temp_handlers
          end
          collected_handlers.sort_by!(&:name)
          collected_handlers.uniq!
          collected_handlers.each { |handler| yielder << handler }
        end
      end
    end

    # Adds the given handler to the set of registered handlers. Optionally, a
    # priority may be supplied. If no priority is supplied the {::default_priority
    # default priority} is used.
    #
    # @param handler [RemotelyExceptional::Handler] The handler that should be
    #   registered.
    # @param options [Hash{Symbol=>Object}] A Hash of optional arguments.
    # @option options [Integer] :priority ({::default_priority}) The priority of
    #   the handler.
    # @return [Boolean] Returns true if the handler was successfully registered
    #   for the given priority. Returns false if the handler was already registered
    #   for the given priority.
    def register_handler(handler, options = {})
      priority = options[:priority] || default_priority
      !!registered_handlers[priority].add?(handler)
    end

    # Returns the Hash of registered handlers by priority.
    #
    # @return [Hash{Integer,Set<RemotelyExceptional::Handler>}] The Hash of
    #   priorities and which handlers belong to those priorities.
    def registered_handlers
      Thread.current["#{name}.registered_handlers"] ||= Hash.new(&HASH_BUILDER)
    end

    # Removes the given handler. By default removes the handler from the
    # {::default_priority default_priority}, but a :priority option may be
    # supplied to remove the handler from a specified priority.
    #
    # @param handler [RemotelyExceptional::Handler] The handler that should be
    #   removed.
    # @param options [Hash{Symbol=>Object}] A Hash of optional arguments.
    # @option options [Integer] :priority ({::default_priority}) The priority that
    #   should be searched for the given handler.
    # @return [Boolean] Returns true if the handler was successfully removed for
    #   the given priority. Returns false if the handler was not registered for
    #   the given priority.
    def remove_handler(handler, options = {})
      priority = options[:priority] || default_priority
      registered_handlers.key?(priority) &&
        !!registered_handlers[priority].delete(handler)
    end

    # Clears all {::block_handlers block handlers} and {::registered_handlers
    # registered handlers}.
    #
    # @return [true]
    def reset_handlers!
      Thread.current["#{name}.registered_handlers"] = nil
      Thread.current["#{name}.block_handlers"] = nil
      true
    end

    # Registers a handler for the duration of the given block. By default
    # registers the block at the {::default_priority default priority}, but a
    # specific priority may be supplied as an option.
    #
    # @param handler [RemotelyExceptional::Handler] The handler that should be
    #   registered.
    # @param options [Hash{Symbol=>Object}] A Hash of optional arguments.
    # @option options [Integer] :priority ({::default_priority}) The priority that
    #   should be used to register the handler.
    # @raise [ArgumentError] if a block is not provided.
    # @return [Boolean] Returns true if the block handler was successfully
    #   registered for the given priority. Returns false if a matching block
    #   handler was already registered for the given priority.
    def with_handler(handler, options = {})
      raise ArgumentError, "Block required!" unless block_given?

      priority = options[:priority] || default_priority
      if block_handlers[priority].add?(handler)
        added_handler = true
      end
      yield
    ensure
      block_handlers[priority].delete(handler) if added_handler
    end
  end
end
