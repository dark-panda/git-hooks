
require 'json'
require GitHooks.shared_path('git_hooks/violation')
require GitHooks.shared_path('git_hooks/violations')

module GitHooks
  module Reek
    class Violations
      include GitHooks::Violations

      def initialize(violations_json, diffs)
        @violations = JSON.parse(violations_json)
        @diffs = diffs
      end

      def violations?
        !@violations.empty?
      end

      def relevant_violations?
        !relevant_violations.empty?
      end

      def relevant_violations
        @relevant_violations ||= @violations.reduce({}) do |memo, violation|
          violation['lines'].each do |line|
            relevant_line = @diffs[violation['source']].relevant_line?(line) or next

            memo[violation['source']] ||= []
            memo[violation['source']] << Violation.new({
              'location' => {
                'line' => line
              },
              'message' => "#{violation['context']} - #{violation['smell_type']} - #{violation['message']}"
            }, relevant_line)
          end

          memo
        end
      end
    end
  end
end
