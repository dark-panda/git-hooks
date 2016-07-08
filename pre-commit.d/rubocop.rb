#!/usr/bin/env ruby

require_relative(File.join(*%w{ .. lib shared }))

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

    cmd = "#{rubocop} #{files.collect { |file|
      Shellwords.escape(file)
    }.join(' ')}"

    output = `#{cmd}`

    if $? != 0
      puts "\n#{msg('/!\\', 'white', 'on_red')} #{msg('WHOA THERE', 'red')}, #{msg('/!\\', 'white', 'on_red')}\n\n"
      puts "Ruby problems in commit! Take a gander at this:\n\n"
      puts "#{output}\n\n"
      exit(1)
    else
      puts "\n#{msg('OK!', 'green')}"
    end
  end
end

exit(0)
