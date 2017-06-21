
module GitHooks
  module Violations
    attr_reader :violations

    def violations?
      @violations['summary']['offense_count'] > 0
    end

    def relevant_violations?
      !relevant_violations.empty?
    end

    def relevant_violations
      @relevant_violations ||= @violations['files'].reduce({}) do |memo, violation|
        violation['offenses'].each do |offense|
          relevant_line = @diffs[violation['path']].relevant_line?(offense['location']['line']) or next

          memo[violation['path']] ||= []
          memo[violation['path']] << Violation.new(offense, relevant_line)
        end

        memo
      end
    end
  end
end
