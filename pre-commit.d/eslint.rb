#!/usr/bin/env ruby

require(File.join(File.expand_path(File.dirname(__FILE__)), *%w{ .. lib shared }))

if !(command = git_config(:'eslint-command')).empty?
  eslint = command
elsif !(eslint = which('eslint'))
  puts "ERROR: Can't find eslint on $PATH"
  exit(127)
end

statuses, files = git_statuses_and_files(/.+(?:\.(?:js|es6))/)

if !files.empty?
  if statuses.include?('AM')
    puts "ERROR: Looks like you've got partially staged JavaScript/ES6."
    puts
    puts "Running eslint on partially staged code could lead to inaccurate"
    puts "results. Please either stage the JavaScript/ES6 files directly or try"
    puts "running eslint on the JavaScript/ES6 files directly and if everything"
    puts "looks good you can commit using \`--no-verify\`."
    exit(127)
  else
    puts msg('Running eslint... ', 'yellow')
    puts "  Checking"
    puts "    #{files.join("\n    ")}"

    cmd = "#{eslint} #{files.collect { |file|
      Shellwords.escape(file)
    }.join(' ')}"

    output = `#{cmd}`

    if $? != 0
      puts "\n#{msg('/!\\', 'white', 'on_red')} #{msg('WHOA THERE', 'red')}, #{msg('/!\\', 'white', 'on_red')}\n\n"
      puts "JavaScript/ES6 problems in commit! Take a gander at this:\n\n"
      puts "#{output}\n\n"
      exit(1)
    else
      puts "\n#{msg('OK!', 'green')}"
    end
  end
end

exit(0)
