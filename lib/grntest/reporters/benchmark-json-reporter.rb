# Copyright (C) 2024  Sutou Kouhei <kou@clear-code.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require "json"
require "time"

require "grntest/reporters/base-reporter"

module Grntest
  module Reporters
    class BenchmarkJSONReporter < BaseReporter
      def initialize(tester)
        super
      end

      def on_start(result)
        puts(<<-JSON)
{
  "context": {"
    "date": #{Time.now.iso8601.to_json},
    "host_name": #{Socket.gethostname.to_json},
    "executable": #{@tester.testee.to_json},
    "num_cpus": #{Etc.nprocessors},
        JSON
        cpu_cycles_per_second = detect_cpu_cycles_per_second
        if cpu_cycles_per_second
          puts(<<-JSON)
    "mhz_per_cpu": #{cpu_cycles_per_second / 1_000_000.0},
          JSON
        end
        puts(<<-JSON)
    "caches": []
  },
  "benchmarks": [
        JSON
      end

      def on_worker_start(worker)
      end

      def on_suite_start(worker)
      end

      def on_test_start(worker)
      end

      def on_test_success(worker, result)
      end

      def on_test_failure(worker, result)
      end

      def on_test_leak(worker, result)
      end

      def on_test_omission(worker, result)
      end

      def on_test_no_check(worker, result)
      end

      def on_test_finish(worker, result)
        return if result.benchmarks.empty?
        benchmarks = result.benchmarks.collect do |benchmark|
          <<-JSON.chomp
    {
      "name": #{result.test_name.to_json},
      "run_name": #{benchmark.name.to_json},
      "run_type": "iteration",
      "iterations": #{benchmark.n_iterations},
      "real_time": #{benchmark.real_elapsed_time},
      "cpu_time": #{benchmark.cpu_elapsed_time},
      "time_unit": "s",
      "items_per_second": #{benchmark.items_per_second},
    }
          JSON
        end
        puts(benchmarks.join(",\n"))
      end

      def on_suite_finish(worker)
      end

      def on_worker_finish(worker)
      end

      def on_finish(result)
        puts(<<-JSON)
  ]
}
        JSON
      end

      private
      def detect_cpu_cycles_per_second
        if File.exist?("/proc/cpuinfo")
          File.open("/proc/cpuinfo") do |cpuinfo|
            cpuinfo.each_line do |line|
              case line
              when /\Acpu MHz\s+: ([\d.]+)/
                return Float($1)
              end
            end
          end
        end
        nil
      end
    end
  end
end
