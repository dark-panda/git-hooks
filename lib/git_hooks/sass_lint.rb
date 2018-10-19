
require 'json'
require GitHooks.shared_path('git_hooks/violation')
require GitHooks.shared_path('git_hooks/violations')

module GitHooks
  module SassLint
    class Violations
      include GitHooks::Violations

      def initialize(violations_json, diffs)
        @violations = parse_violations(violations_json)
        @diffs = diffs
      end

      def fix_path(path)
        path.sub(/^#{GitHooks::GitUtils.git_base_path}\/?/, '')
      end

      def parse_violations(violations_json)
        json = JSON.parse(violations_json)

        violations = {}

        json.each do |violation|
          violations['files'] ||= []

          file_violation = {
            'path' => fix_path(violation['filePath']),
            'offenses' => []
          }

          violation['messages'].each do |message|
            file_violation['offenses'] << {
              'severity' => message['severity'],
              'message' => message['message'],
              'location' => {
                'line' => message['line'].to_i,
                'column' => message['column'].to_i
              }
            }
          end

          violations['files'] << file_violation
        end

        violations
      end
    end
  end
end
