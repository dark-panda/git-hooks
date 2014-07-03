#!/usr/bin/env ruby

require_relative(File.join(*%w{ .. lib shared }))

statuses, files = git_statuses_and_files(/(.+(?:\.(?:rake|rb|builder|jbuilder|ru))|Gemfile|Rakefile|Guardfile|Capfile)/)

if !files.empty?
  begin
    gem 'rubocop', '~> 0.24'
    require 'rubocop'
  rescue LoadError
    puts "NOTE: RuboCop cannot be found. Please check your gem configuration or"
    puts "disable the #{__FILE__} hook."
    exit(1)
  end

  if defined?(Rubocop)
    RuboCop = Rubocop
  end

  require_relative(File.join(*%w{ .. lib hound }))

  style_guide = Hound::StyleGuide.new
  diff = Hound::Diff.new(git_diff(:cached))
  formatter = RuboCop::Formatter::ClangStyleFormatter.new($stdout)

  puts msg('Running RuboCop... ', 'yellow')
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
