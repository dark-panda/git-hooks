#!/usr/bin/env ruby

require File.join(File.expand_path(File.dirname(__FILE__)), *%w{ .. lib git_hooks })
require GitHooks.shared_path('git_hooks/git_utils')

eslint = GitHooks.fetch_command('eslint', 'eslint')
statuses, files = GitHooks::GitUtils.git_statuses_and_files(/.+(?:\.(?:js|es6))/)

if !files.empty?
  if statuses.include?('AM')
    puts GitHooks.partially_staged_code('JavaScript')
    exit(127)
  else
    puts <<~TEXT
      #{GitHooks.running('eslint')}

      #{GitHooks.checking_files(files)}
    TEXT

    cmd = "#{eslint} #{files.collect { |file|
      Shellwords.escape(file)
    }.join(' ')}"

    output = `#{cmd}`

    if $? != 0
      puts GitHooks.whoa_there
      puts "JavaScript/ES6 problems in commit! Take a gander at this:\n\n"
      puts "#{output}\n\n"
      exit(1)
    else
      puts GitHooks.ok
    end
  end
end

exit(0)
