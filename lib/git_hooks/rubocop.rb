
module GitHooks
  module Rubocop
    class Violation < Struct.new(:offense, :relevant_line)
      def line_number
        offense['location']['line']
      end

      def column_number
        offense['location']['column']
      end

      def severity
        offense['severity']
      end

      def message
        offense['message']
      end

      def line_content
        relevant_line.content
      end
    end

    class Violations
      attr_reader :violations

      def initialize(violations_json, diffs)
        @violations = JSON.parse(violations_json)
        @diffs = diffs
      end

      def violations?
        @violations['summary']['offense_count'] > 0
      end

      def relevant_violations?
        !relevant_violations.empty?
      end

      def relevant_violations
        @relevant_violations ||= @violations['files'].each_with_object({}) do |violation, memo|
          violation['offenses'].each do |offense|
            relevant_line = @diffs[violation['path']].relevant_line?(offense['location']['line']) or next

            memo[violation['path']] ||= []
            memo[violation['path']] << Violation.new(offense, relevant_line)
          end
        end
      end
    end
  end
end
