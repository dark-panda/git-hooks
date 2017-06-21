
module GitHooks
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
end
