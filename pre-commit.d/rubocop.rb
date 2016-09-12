#!/usr/bin/env ruby

require 'json'
require File.join(File.expand_path(File.dirname(__FILE__)), *%w{ .. lib shared })
require shared_path('git_hooks/git_tools')
require shared_path('git_hooks/rubocop')

if !(command = git_config(:'rubocop-command')).empty?
  rubocop = command
elsif !(rubocop = which('rubocop'))
  puts "ERROR: Can't find rubocop on $PATH"
  exit(127)
end

statuses, files = git_statuses_and_files(/(.+(?:\.(?:rake|rb|builder|jbuilder|ru))|Gemfile|Rakefile|Guardfile|Capfile)/)

if !files.empty?
  if statuses.include?('AM')
    puts "ERROR: Looks like you've got partially staged Ruby code."
    puts
    puts "Running rubocop on partially staged code could lead to inaccurate"
    puts "results. Please either stage the Ruby files directly or try"
    puts "running rubocop on the Ruby files directly and if everything"
    puts "looks good you can commit using \`--no-verify\`."
    exit(127)
  else
    puts msg('Running rubocop... ', 'yellow')
    puts "  Checking"
    puts "    #{files.join("\n    ")}"

    cmd = "#{rubocop} --format json #{files.collect { |file|
      Shellwords.escape(file)
    }.join(' ')}"

    output = `#{cmd}`

    if $? != 0
      diffs = GitHooks::GitTools::Diff.new(git_diff(:cached))
      violations = GitHooks::Rubocop::Violations.new(output, diffs)

      if violations.relevant_violations?
        puts "\n#{msg('/!\\', 'white', 'on_red')} #{msg('WHOA THERE', 'red')}, #{msg('/!\\', 'white', 'on_red')}\n\n"
        puts "Ruby problems in commit! Take a gander at this:\n\n"

        violations.relevant_violations.each do |file, violations|
          violations.each do |violation|
            puts "#{file}:#{violation.line_number}:#{violation.column_number}:#{violation.severity}: #{violation.message}"
            puts "\t#{violation.line_content}"
            puts
          end
        end

        exit(1)
      end
    end
  end
end

puts "\n#{msg('OK!', 'green')}"
exit(0)
