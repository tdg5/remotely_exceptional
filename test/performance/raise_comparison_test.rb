require "test_helper"
require "benchmark"
require "minitest_benchmark_tests"

class RaiseComparisonTest < RemotelyExceptional::TestCase
  include MinitestBenchmarkTests::RelativePerformanceTestCase
  class TestStrategy
    class << self
      attr_accessor :action
    end

    def self.===(exception)
      exception.is_a?(ArgumentError)
    end

    def self.handle(remote_exception)
      action == :retry ? remote_exception.retry : remote_exception.continue
    end
  end

  class TestIncluder
    include RemotelyExceptional::RemoteHandling
  end

  context "relative to raise" do
    should "perform between 2.0 slower when continuing" do
      TestStrategy.action = :continue

      standard = lambda do
        begin
          raise ArgumentError
        rescue ArgumentError
        end
      end

      candidate = lambda do
        TestIncluder.remotely_exceptional(TestStrategy) do
          raise ArgumentError
        end
      end

      opts = {
        :factor => 2.0,
      }

      assert_relative_performance(standard, candidate, opts)
    end

    should "perform less than 2x slower when retrying" do
      TestStrategy.action = :retry

      standard = lambda do
        should_retry = false

        begin
          unless should_retry
            should_retry = true
            raise ArgumentError
          end
        rescue ArgumentError
          retry
        end
      end

      candidate = lambda do
        should_retry = false

        TestIncluder.remotely_exceptional(TestStrategy) do
          unless should_retry
            should_retry = true
            raise ArgumentError
          end
        end
      end

      opts = {
        :factor => 2.0,
      }

      assert_relative_performance(standard, candidate, opts)
    end
  end

  # Skip iterations [1, 10] because they're too variable.
  def bench_range
    @bench_range ||= 2.upto(4).map { |n| 10 ** n }
  end
end
