
require 'json'
require GitHooks.shared_path('git_hooks/violation')
require GitHooks.shared_path('git_hooks/violations')

module GitHooks
  module Rubocop
    class Violations
      include GitHooks::Violations

      def initialize(violations_json, diffs)
        @violations = JSON.parse(violations_json)
        @diffs = diffs
      end

      def violation_class
        GitHooks::Rubocop::Violation
      end
    end

    class Violation < GitHooks::Violation
      def message
        "#{offense['cop_name']} - #{offense['message']}"
      end
    end
  end
end
