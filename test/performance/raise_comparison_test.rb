require "test_helper"
require "benchmark"

class RaiseComparisonTest < RemotelyExceptional::TestCase
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

  context "compared to raise" do
    setup do
      was_disabled = GC.enable
      GC.start
      # Sleep briefly if the GC wasn't previously disabled for more consistent
      # execution.
      sleep 0.1 unless was_disabled
      GC.disable
    end

    should "perform between 2.0 - 3.5x slower when continuing" do
      TestStrategy.action = :continue
      bench_range.each do |bench_size|
        raise_time = remotely_exceptional_time = 0

        bench_size.times do
          raise_time += Benchmark.realtime do
            begin
              raise ArgumentError
            rescue ArgumentError
            end
          end

          remotely_exceptional_time += Benchmark.realtime do
            TestIncluder.remotely_exceptional(TestStrategy) do
              raise ArgumentError
            end
          end
        end

        # Allow a little more leeway for benchmarks of 100 or less iterations.
        epsilon = bench_size <= 100 ? 3.5 : 2.0
        real_epsilon = (remotely_exceptional_time / raise_time) - 1
        fail_msg = "bench size: #{bench_size} | expected_epsilon: #{epsilon} | real_epsilon: #{real_epsilon}"
        assert_in_epsilon(raise_time, remotely_exceptional_time, epsilon, fail_msg)
      end
    end

    should "perform between 2.0 - 3.5x slower when retrying" do
      TestStrategy.action = :retry
      bench_range.each do |bench_size|
        raise_time = remotely_exceptional_time = 0

        bench_size.times do
          should_retry = false
          raise_time += Benchmark.realtime do
            begin
              unless should_retry
                should_retry = true
                raise ArgumentError
              end
            rescue ArgumentError
              retry
            end
          end

          should_retry = false
          remotely_exceptional_time += Benchmark.realtime do
            TestIncluder.remotely_exceptional(TestStrategy) do
              unless should_retry
                should_retry = true
                raise ArgumentError
              end
            end
          end
        end

        # Allow a little more leeway for benchmarks of 100 or less iterations.
        epsilon = bench_size <= 100 ? 3.5 : 2.0
        real_epsilon = (remotely_exceptional_time / raise_time) - 1
        fail_msg = "bench size: #{bench_size} | expected_epsilon: #{epsilon} | real_epsilon: #{real_epsilon}"
        assert_in_epsilon(raise_time, remotely_exceptional_time, epsilon, fail_msg)
      end
    end
  end

  # Skip iterations [1, 10] because they're too variable.
  def bench_range
    @bench_range ||= 2.upto(4).map { |n| 10 ** n }
  end
end
