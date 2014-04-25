#!/usr/bin/env ruby

require_relative(File.join(*%w{ .. lib shared }))

statuses, files = git_statuses_and_files(/(.+(?:\.(?:rake|rb|builder|jbuilder|ru))|Gemfile|Rakefile|Guardfile|Capfile)/)

if !files.empty?
  begin
    gem 'rubocop', '~> 0.21'
    require 'rubocop'
  rescue LoadError
    puts "NOTE: Rubocop cannot be found. Please check your gem configuration or"
    puts "disable the #{__FILE__} hook."
    exit(1)
  end

  class StyleGuide
    def initialize(config = nil)
      @config = config
    end

    def violations(file_content)
      investigate(parse_file_content(file_content))
    end

    def relevant_violations(file_content, patch)
      violations(file_content).select do |violation|
        patch.relevant_line?(violation.line)
      end
    end

    private

    def investigate(parsed_file_content)
      unless parsed_file_content.valid_syntax?
        diagnostics = parsed_file_content.diagnostics
        return Rubocop::Cop::Lint::Syntax.offenses_from_diagnostics(diagnostics)
      end

      team = Rubocop::Cop::Team.new(Rubocop::Cop::Cop.all, configuration)
      commissioner = Rubocop::Cop::Commissioner.new(team.cops, team.forces)
      commissioner.investigate(parsed_file_content)
    end

    def parse_file_content(file_content)
      Rubocop::SourceParser.parse(file_content)
    end

    def configuration
      if @config
        config = YAML.load(@config)
        Rubocop::Config.new(config)
      elsif File.exists?('config/rubocop.yml')
        Rubocop::ConfigLoader.load_file('config/rubocop.yml')
      elsif File.exists?('.rubocop.yml')
        Rubocop::ConfigLoader.load_file('.rubocop.yml')
      else
        Rubocop::Config.new
      end
    end
  end

  require_relative(File.join(*%w{ .. lib hound }))

  style_guide = StyleGuide.new
  diff = Hound::Diff.new(git_diff(:cached))
  formatter = Rubocop::Formatter::ClangStyleFormatter.new($stdout)

  puts msg('Running Rubocop... ', 'yellow')
  puts "  Checking"
  puts "    #{files.join("\n    ")}"

  all_violations = files.each_with_object({}) do |file, memo|
    patch = diff[file]
    violations = style_guide.relevant_violations(File.read(file), patch)

    if !violations.empty?
      memo[file] = violations
    end
  end

  if !all_violations.empty?
    puts "\n#{msg('/!\\', 'white', 'on_red')} #{msg('WHOA THERE', 'red')}, #{msg('/!\\', 'white', 'on_red')}\n\n"
    puts "Ruby problems in commit! Take a gander at this:\n\n"

    all_violations.each do |file, violations|
      formatter.report_file(file, violations)
    end

    exit(1)
  else
    puts "\n#{msg('OK!', 'green')}"
  end
end

exit(0)
