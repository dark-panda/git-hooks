
require 'rexml/document'
require GitHooks.shared_path('git_hooks/violation')
require GitHooks.shared_path('git_hooks/violations')

module GitHooks
  module Checkstyle
    class Violations
      include GitHooks::Violations

      attr_reader :violations

      def initialize(violations_xml, diffs)
        @violations = parse_violations(violations_xml)
        @diffs = diffs
      end

      def fix_path(path)
        path.sub(/^#{GitHooks::GitUtils.git_base_path}\/?/, '')
      end

      def parse_violations(violations_xml)
        xml = REXML::Document.new(violations_xml).root

        violations = {}

        xml.elements.each('file') do |file|
          next if file.elements.empty?

          violations['files'] ||= []

          file_violation = {
            'path' => fix_path(file[:name]),
            'offenses' => []
          }

          violations['files'] << file_violation

          file.elements.each('error') do |error|
            file_violation['offenses'] << {
              'severity' => error[:severity],
              'message' => error[:message],
              'location' => {
                'line' => error[:line].to_i,
                'column' => error[:column].to_i
              }
            }
          end
        end

        violations
      end
    end
  end
end
