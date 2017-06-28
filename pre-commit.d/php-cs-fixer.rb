#!/usr/bin/env ruby

require(File.join(File.expand_path(File.dirname(__FILE__)), *%w{ .. lib git_hooks }))
require GitHooks.shared_path('git_hooks/git_utils')

php_cs_fixer = GitHooks.fetch_command('php-cs-fixer', 'php-cs-fixer')
statuses, files = GitHooks::GitUtils.git_statuses_and_files(/.+\.php/)

if !files.empty?
  if statuses.include?('AM')
    puts GitHooks.partially_staged_code('PHP', 'php-cs-fixer')
    exit(127)
  else
    puts <<~TEXT
      #{GitHooks.running('php-cs-fixer')}

      #{GitHooks.checking_files(files)}
    TEXT

    outputs = []
    exit_statuses = []

    files.each { |file|
      cmd = "cat #{Shellwords.escape(file)} | #{php_cs_fixer} fix --diff -"
      outputs << `#{cmd}`
      exit_statuses << $?
    }

    has_errors = !exit_statuses.map(&:to_i).all?(&:zero?)

    if has_errors
      puts GitHooks.whoa_there
      puts "PHP problems in commit! Take a gander at this:\n\n"

      outputs.each do |output|
        puts output
      end

      exit(1)
    else
      puts GitHooks.ok
    end
  end
end

exit(0)
