# Copyright (C) 2012-2023  Sutou Kouhei <kou@clear-code.com>
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

require "grntest/reporters/base-reporter"

module Grntest
  module Reporters
    class StreamReporter < BaseReporter
      def initialize(tester)
        super
      end

      def on_start(result)
      end

      def on_worker_start(worker)
      end

      def on_suite_start(worker)
        return unless single_worker?
        if worker.suite_name.bytesize <= @term_width
          puts(worker.suite_name)
        else
          puts(justify(worker.suite_name, @term_width))
        end
        @output.flush
      end

      def on_test_start(worker)
        synchronize do
          if single_worker?
            print("  #{worker.test_name}")
          else
            report_full_test_name(worker)
            report_right_message("[start]")
          end
          @output.flush
        end
      end

      def on_test_success(worker, result)
        synchronize do
          report_full_test_name(worker) unless single_worker?
          report_test_result(result, worker.status)
        end
      end

      def on_test_failure(worker, result)
        synchronize do
          report_full_test_name(worker) unless single_worker?
          report_test_result(result, worker.status)
          report_failure(result)
        end
      end

      def on_test_leak(worker, result)
        synchronize do
          report_full_test_name(worker) unless single_worker?
          report_test_result(result, worker.status)
          report_actual(result) unless result.checked?
        end
      end

      def on_test_omission(worker, result)
        synchronize do
          report_full_test_name(worker) unless single_worker?
          report_test_result(result, worker.status)
          report_actual(result)
        end
      end

      def on_test_omission_suppressed(worker, result)
        synchronize do
          report_full_test_name(worker) unless single_worker?
          report_test_result(result, worker.status)
        end
      end

      def on_test_no_check(worker, result)
        synchronize do
          report_full_test_name(worker) unless single_worker?
          report_test_result(result, worker.status)
          report_actual(result)
        end
      end

      def on_test_finish(worker, result)
      end

      def on_suite_finish(worker)
      end

      def on_worker_finish(worker_id)
      end

      def on_finish(result)
        puts
        report_summary(result)
      end
    end
  end
end
