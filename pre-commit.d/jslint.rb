#!/usr/bin/env ruby

require 'shellwords'

$: << '.'
require File.join(File.dirname(__FILE__), *%w{ .. lib shared })

if !(jslint = which('jslint'))
  puts "ERROR: Can't find jslint on $PATH"
  exit(127)
end

status = `git status --porcelain`
statuses_and_files = status.scan(/^\s*([AM]+)\s+(.+\.js)$/).compact
statuses = statuses_and_files.collect(&:first)
files = statuses_and_files.collect(&:last)

if !files.empty?
  if statuses.include?('AM')
    puts "ERROR: Looks like you've got partially staged JavaScript."
    puts
    puts "Running jslint on partially staged code could lead to inaccurate"
    puts "results. Please either stage the JavaScript files directly or try"
    puts "running jslint on the JavaScript files directly and if everything"
    puts "looks good you can commit using \`--no-verify\`."
    exit(127)
  else
    puts msg('Running jslint... ', 'yellow')
    puts "  Checking"
    puts "    #{files.join("\n    ")}"

    cmd = "#{jslint} #{files.collect { |file|
      Shellwords.escape(file)
    }.join(' ')}"

    output = `#{cmd}`

    if $? != 0
      puts "\n#{msg('/!\\', 'white', 'on_red')} #{msg('WHOA THERE', 'red')}, #{msg('/!\\', 'white', 'on_red')}\n\n"
      puts "JavaScript problems in commit! Take a gander at this:\n\n"
      puts "#{output}\n\n"
      exit(1)
    else
      puts "\n#{msg('OK!', 'green')}"
    end
  end
end

exit(0)
