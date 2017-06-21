#!/usr/bin/env ruby

require 'rubygems'
require File.join(File.expand_path(File.dirname(__FILE__)), *%w{ .. lib shared })
require shared_path('git_hooks/git_tools')
require shared_path('git_hooks/checkstyle')

if !(command = git_config(:'checkstyle-command')).empty?
  checkstyle = command
elsif !(checkstyle = which('checkstyle'))
  puts "ERROR: Can't find checkstyle on $PATH"
  exit(127)
end

statuses, files = git_statuses_and_files(/(.+(?:\.(?:java)))/)

if !files.empty?
  if statuses.include?('AM')
    puts "ERROR: Looks like you've got partially staged Java code."
    puts
    puts "Running checkstyle on partially staged code could lead to inaccurate"
    puts "results. Please either stage the Java files directly or try"
    puts "running checkstyle on the Java files directly and if everything"
    puts "looks good you can commit using \`--no-verify\`."
    exit(127)
  else
    puts msg('Running checkstyle... ', 'yellow')
    puts "  Checking"
    puts "    #{files.join("\n    ")}"

    cmd = "#{checkstyle} -f xml #{files.collect { |file|
      Shellwords.escape(file)
    }.join(' ')}"

    output = `#{cmd}`

    diffs = GitHooks::GitTools::Diff.new(git_diff(:cached))
    violations = GitHooks::Checkstyle::Violations.new(output, diffs)

    if violations.relevant_violations?
      puts "\n#{msg('/!\\', 'white', 'on_red')} #{msg('WHOA THERE', 'red')}, #{msg('/!\\', 'white', 'on_red')}\n\n"
      puts "Java problems in commit! Take a gander at this:\n\n"

      violations.relevant_violations.each do |file, violations|
        violations.each do |violation|
          puts "#{file}:#{violation.line_number}:#{violation.column_number}:#{violation.severity}: #{violation.message}"
          puts "\t#{violation.line_content}"
          puts
        end
      end

      exit(1)
    end

    puts "\n#{msg('OK!', 'green')}"
  end
end

exit(0)
