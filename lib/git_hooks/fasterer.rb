
module GitHooks
  module Fasterer
    class Violation < Struct.new(:offense, :relevant_line)
      def line_number
        offense['line_number']
      end

      def column_number
        nil
      end

      def severity
        nil
      end

      def message
        offense['message']
      end

      def line_content
        relevant_line.content
      end
    end

    class ViolationsParser < Struct.new(:violations_text)
      def self.parse(violations_text)
        self.new(violations_text).parse
      end

      def parse
        violations = {}
        file = nil

        violations_text.each_line do |line|
          line = line.gsub(/\e\[([;\d]+)m/, '').strip

          if line =~ /(.+) Occurred at lines: ([\d\s,]+)\.$/
            violations[file] ||= []

            $2.split(',').collect do |line_number|
              violations[file] << {
                'message' => $1,
                'line_number' => line_number.to_i
              }
            end
          else
            file = line
          end
        end

        violations
      end
    end

    class Violations
      attr_reader :violations

      def initialize(violations_text, diffs)
        @violations = ViolationsParser.parse(violations_text)
        @diffs = diffs
      end

      def violations?
        @violations['summary']['offense_count'] > 0
      end

      def relevant_violations?
        !relevant_violations.empty?
      end

      def relevant_violations
        @relevant_violations ||= @violations.reduce({}) do |memo, (file, violations)|
          violations.each do |offense|
            relevant_line = @diffs[file].relevant_line?(offense['line_number']) or next

            memo[file] ||= []
            memo[file] << Violation.new(offense, relevant_line)
          end

          memo
        end
      end
    end
  end
end
