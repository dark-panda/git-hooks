
require shared_path('git_hooks/violation')
require shared_path('git_hooks/violations')

module GitHooks
  module Rubocop
    class Violations
      include GitHooks::Violations

      def initialize(violations_json, diffs)
        @violations = JSON.parse(violations_json)
        @diffs = diffs
      end
    end
  end
end
