#!/usr/bin/env ruby

require(File.join(File.expand_path(File.dirname(__FILE__)), *%w{ .. lib shared }))
require shared_path('git_hooks/git_tools')
require shared_path('git_hooks/fasterer')

if !(command = git_config(:'fasterer-command')).empty?
  fasterer = command
elsif !(fasterer = which('fasterer'))
  puts "ERROR: Can't find fasterer on $PATH"
  exit(127)
end

statuses, files = git_statuses_and_files(/(.+(?:\.(?:rake|rb|builder|jbuilder|ru))|Gemfile|Rakefile|Guardfile|Capfile)/)

if !files.empty?
  if statuses.include?('AM')
    puts "ERROR: Looks like you've got partially staged Ruby code."
    puts
    puts "Running fasterer on partially staged code could lead to inaccurate"
    puts "results. Please either stage the Ruby files directly or try"
    puts "running fasterer on the Ruby files directly and if everything"
    puts "looks good you can commit using \`--no-verify\`."
    exit(127)
  else
    puts msg('Running fasterer... ', 'yellow')
    puts "  Checking"
    puts "    #{files.join("\n    ")}"

    exit_value = nil

    files.each do |file|
      cmd = "#{fasterer} #{Shellwords.escape(file)}"
      output = `#{cmd}`

      next if $? == 0

      diffs = GitHooks::GitTools::Diff.new(git_diff(:cached))
      violations = GitHooks::Fasterer::Violations.new(output, diffs)

      next unless violations.relevant_violations?

      exit_value = 10

      puts "\n#{msg('/!\\', 'white', 'on_red')} #{msg('WHOA THERE', 'red')}, #{msg('/!\\', 'white', 'on_red')}\n\n"
      puts "Ruby problems in commit! Take a gander at this:\n\n"

      violations.relevant_violations.each do |file, violations|
        violations.each do |violation|
          puts "#{file}:#{violation.line_number}: #{violation.message}"
          puts "\t#{violation.line_content}"
          puts
        end
      end
    end

    exit(exit_value) if exit_value

    puts "\n#{msg('OK!', 'green')}"
  end
end

exit(0)
