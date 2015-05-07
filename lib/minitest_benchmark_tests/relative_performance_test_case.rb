require "benchmark"

module MinitestBenchmarkTests::RelativePerformanceTestCase
  def assert_relative_performance(standard, candidate, opts = {})
    factor = opts[:factor] || 1.0
    bench_sizes = opts[:bench_range]
    bench_sizes ||= respond_to?(:bench_range) ? bench_range : []
    allowed_deviation = opts[:allowed_deviation] || 0.35

    standard_results = []
    candidate_results = []

    bench_sizes.each do |bench_size|
      next if bench_size.zero?

      standard_results = generate_result_set(bench_size, standard, allowed_deviation)
      candidate_results = generate_result_set(bench_size, candidate, allowed_deviation)

      standard_average = standard_results.inject(:+) / bench_size.to_f
      candidate_average = candidate_results.inject(:+) / bench_size.to_f

      assert_in_epsilon(standard_average, candidate_average, factor)
    end
  end

  private

  def generate_result_set(size, func, allowed_deviation)
    3.times do
      results = try_generate_result_set(:conservative, size, func, allowed_deviation)
      return results if results
    end
    3.times do
      results = try_generate_result_set(:aggresive, size, func, allowed_deviation)
      return results if results
    end
    raise "Could not generate reliable result set!"
  end

  def try_generate_result_set(strategy, size, func, allowed_deviation)
    if strategy == :conservative
      results = conservative_gc_generate_result_set(size, func, allowed_deviation)
    else
      results = aggresive_gc_generate_result_set(size, func, allowed_deviation)
    end

    average = results.inject(:+) / size.to_f
    std_dev = standard_deviation(results, average)
    # Ensure results are in tolerable sigma range
    average_sigma = results.map { |i| (i - average).abs / std_dev }.inject(:+) / size
    average_sigma <= allowed_deviation ? results : false
  end

  def conservative_gc_generate_result_set(size, func, allowed_deviation)
    results = []
    normalize_gc do
      while results.length < size
        results << Benchmark.realtime(&func)
      end
    end
    results
  end

  def aggresive_gc_generate_result_set(size, func, allowed_deviation)
    results = []
    result_collector = lambda { results << Benchmark.realtime(&func) }
    while results.length < size
      normalize_gc(&result_collector)
    end
    results
  end

  def standard_deviation(collection, average = nil)
    collection_length = collection.length.to_f
    average ||= collection.inject(:+) / collection_length
    squared_differences = collection.map { |i| (i - average) ** 2 }
    variance = squared_differences.inject(:+) / collection_length
    Math.sqrt(variance)
  end

  def normalize_gc
    GC.enable
    GC.start
    if block_given?
      GC.disable
      yield
      GC.enable
    end
  end
end
