#!/usr/bin/env ruby

require(File.join(File.expand_path(File.dirname(__FILE__)), *%w{ .. lib shared }))

if !(command = git_config(:'php-cs-fixer-command')).empty?
  php_cs_fixer = command
elsif !(php_cs_fixer = which('php-cs-fixer'))
  puts "ERROR: Can't find php-cs-fixer on $PATH"
  exit(127)
end

statuses, files = git_statuses_and_files(/.+\.php/)

if !files.empty?
  if statuses.include?('AM')
    puts "ERROR: Looks like you've got partially staged PHP."
    puts
    puts "Running php-cs-fixer on partially staged code could lead to inaccurate"
    puts "results. Please either stage the PHP files directly or try"
    puts "running php-cs-fixer on the PHP files directly and if everything"
    puts "looks good you can commit using \`--no-verify\`."
    exit(127)
  else
    puts msg('Running php-cs-fixer... ', 'yellow')
    puts "  Checking"
    puts "    #{files.join("\n    ")}"

    outputs = []
    exit_statuses = []

    files.each { |file|
      cmd = "cat #{Shellwords.escape(file)} | #{php_cs_fixer} fix --diff -"
      outputs << `#{cmd}`
      exit_statuses << $?
    }

    has_errors = !exit_statuses.map(&:to_i).all?(&:zero?)

    if has_errors
      puts "\n#{msg('/!\\', 'white', 'on_red')} #{msg('WHOA THERE', 'red')}, #{msg('/!\\', 'white', 'on_red')}\n\n"
      puts "PHP problems in commit! Take a gander at this:\n\n"

      outputs.each do |output|
        puts output
      end

      exit(1)
    else
      puts "\n#{msg('OK!', 'green')}"
    end
  end
end

exit(0)
