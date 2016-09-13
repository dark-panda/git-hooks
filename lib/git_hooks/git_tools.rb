
module GitHooks
  module GitTools
    class Line < Struct.new(:content, :line_number, :patch_position)
      def ==(other_line)
        content == other_line.content
      end
    end

    class Diff
      def initialize(body)
        @body = body || ''
      end

      def patches
        return @patches if defined?(@patches)

        parts = @body.split(%r{^diff --git a/(?:.+) b/(.+)$})
        parts.shift

        @patches = {}

        while !parts.empty?
          filename, diff = parts.shift(2)
          @patches[filename] = Patch.new(diff)
        end

        @patches
      end

      def patch(file)
        patches[file]
      end
      alias_method :[], :patch
    end

    class Patch
      RANGE_INFORMATION_LINE = /^@@ .+\+(\d+),/
      MODIFIED_LINE = /^\+(?!\+|\+)/
      NOT_REMOVED_LINE = /^[^-]/

      def initialize(body)
        @body = body || ''
      end

      def additions
        return @additions if defined?(@additions)

        line_number = 0

        @additions = lines.each_with_index.inject([]) do |additions, (content, patch_position)|
          case content
          when RANGE_INFORMATION_LINE
            line_number = Regexp.last_match[1].to_i
          when MODIFIED_LINE
            additions << Line.new(content, line_number, patch_position)
            line_number += 1
          when NOT_REMOVED_LINE
            line_number += 1
          end

          additions
        end
      end

      def relevant_line?(line_number)
        additions.detect do |addition|
          addition.line_number == line_number
        end
      end

      private
        def lines
          @body.lines
        end
    end
  end
end
