#!/usr/bin/env ruby

require File.join(File.expand_path(File.dirname(__FILE__)), *%w{ .. lib shared })
require shared_path('git_hooks/git_tools')

statuses, files = git_statuses_and_files(/(.+\.erb$)/)

if !files.empty?
  if statuses.include?('AM')
    puts "ERROR: Looks like you've got partially staged ERB code."
    puts
    puts "Running rubocop on partially staged code could lead to inaccurate"
    puts "results. Please either stage the ERB files directly or try"
    puts "running the ERB check on the ERB files directly and if everything"
    puts "looks good you can commit using \`--no-verify\`."
    exit(127)
  else
    if !(command = git_config(:'erb-check-command')).empty?
      erb_check = command
    elsif erb_check = which('erb')
      erb_check = "#{erb_check} -x"
    else
      puts "ERROR: Can't find erb on $PATH"
      exit(127)
    end

    puts msg('Running ERB checks... ', 'yellow')
    puts "  Checking"
    puts "    #{files.join("\n    ")}"

    cmd = "#{erb_check} #{files.collect { |file|
      Shellwords.escape(file)
    }.join(' ')}"

    output = `#{cmd}`

    if $? != 0
      puts "\n#{msg('/!\\', 'white', 'on_red')} #{msg('WHOA THERE', 'red')}, #{msg('/!\\', 'white', 'on_red')}\n\n"
      puts "ERB problems in commit! Take a gander at this:\n\n"
      puts "#{output}\n"

      exit(1)
    end

    puts "\n#{msg('OK!', 'green')}"
  end
end

exit(0)
