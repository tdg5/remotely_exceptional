class RemotelyExceptional::Handlers::PrioritizedHandler
  include RemotelyExceptional::Handler
  DEFAULT_PRIORITY = 1000
  HASH_BUILDER = lambda { |hash, key| hash[key] = Set.new }

  def self.block_handlers
    Thread.current["#{name}.block_handlers"] ||= Hash.new(&HASH_BUILDER)
  end
  private_class_method :block_handlers

  def self.default_priority
    const_get(:DEFAULT_PRIORITY)
  end

  def self.prioritized_handlers
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

  def self.register_handler(handler, options = {})
    priority = options[:priority] || default_priority
    !!registered_handlers[priority].add?(handler)
  end

  def self.registered_handlers
    Thread.current["#{name}.registered_handlers"] ||= Hash.new(&HASH_BUILDER)
  end
  private_class_method :registered_handlers

  def self.remove_handler(handler, options = {})
    priority = options[:priority] || default_priority
    !!registered_handlers[priority].delete(handler)
  end

  def self.reset_handlers!
    Thread.current["#{name}.registered_handlers"] = nil
    Thread.current["#{name}.block_handlers"] = nil
  end

  def self.with_handler(handler, options = {})
    raise ArgumentError, "Block required!" unless block_given?

    priority = options[:priority] || default_priority
    if block_handlers[priority].add?(handler)
      added_handler = true
    end
    yield
  ensure
    block_handlers[priority].delete(handler) if added_handler
  end

  def handle

  end
end
