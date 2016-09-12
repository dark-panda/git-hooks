#!/usr/bin/env ruby

require(File.join(File.expand_path(File.dirname(__FILE__)), *%w{ .. lib shared }))

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

    cmd = "#{fasterer} #{files.collect { |file|
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
