class RemotelyExceptional::Handlers::PrioritizedHandler
  include RemotelyExceptional::Handler
  DEFAULT_PRIORITY = 1000
  HASH_BUILDER = lambda { |hash, key| hash[key] = Set.new }

  def initialize
    @handlers = Hash.new(&HASH_BUILDER)
    @temporary_handlers = Hash.new(&HASH_BUILDER)
  end

  def self.default_priority
    const_get(:DEFAULT_PRIORITY)
  end

  def self.prioritized_handlers
    Enumerator.new do |yielder|
      keys = (@handlers.keys | @temporary_handlers.keys).sort!
      keys.uniq!
      keys.each do |key|
        handlers = @handlers[key].to_a if @handlers.key?(key)
        if @temporary_handlers.key?(key)
          temp_handlers = @temporary_handlers[key].to_a
          handlers = handlers ? handlers.concat(temp_handlers) : temp_handlers
        end
        handlers.sort_by!(&:name)
        handlers.uniq!
        handlers.each { |handler| yielder << handler }
      end
    end
  end

  def self.clear_handlers
    @handlers = Hash.new(&HASH_BUILDER)
    @temporary_handlers = Hash.new(&HASH_BUILDER)
  end

  def self.register_handler(handler, options = {})
    priority = options[:priority] || default_priority
    !!@handlers[priority].add?(handler)
  end

  def self.remove_handler(handler, options = {})
    priority = options[:priority] || default_priority
    !!@handlers[priority].delete(handler)
  end

  def self.with_handler(handler, options = {})
    raise ArgumentError, "Block required!" unless block_given?
    priority = options[:priority] || default_priority
    if @temporary_handlers[priority].add?(handler)
      added_handler = true
    end
    yield
  ensure
    @temporary_handlers[priority].delete(handler) if added_handler
  end

  def handle

  end
end
