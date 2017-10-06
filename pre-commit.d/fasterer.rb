#!/usr/bin/env ruby

require File.join(File.expand_path(File.dirname(__FILE__)), *%w{ .. lib git_hooks })
require GitHooks.shared_path('git_hooks/git_tools')
require GitHooks.shared_path('git_hooks/git_utils')
require GitHooks.shared_path('git_hooks/fasterer')

fasterer = GitHooks.fetch_command('fasterer', 'fasterer')
statuses, files = GitHooks::GitUtils.git_statuses_and_files(/(.+(?:\.(?:rake|rb|builder|jbuilder|ru))|Gemfile|Rakefile|Guardfile|Capfile)/)

if !files.empty?
  if statuses.include?('AM')
    puts GitHooks.partially_staged_code('Ruby', 'fasterer')
    exit(127)
  else
    puts <<~TEXT
      #{GitHooks.running('fasterer')}

      #{GitHooks.checking_files(files)}
    TEXT

    exit_value = nil

    files.each do |file|
      cmd = "#{fasterer} #{Shellwords.escape(file)}"
      output = `#{cmd}`

      next if $? == 0

      diffs = GitHooks::GitTools::Diff.new(git_diff(:cached))
      violations = GitHooks::Fasterer::Violations.new(output, diffs)

      next unless violations.relevant_violations?

      exit_value = 10

      puts GitHooks.whoa_there
      puts GitHooks.show_violations(violations)
    end

    exit(exit_value) if exit_value

    puts GitHooks.ok
  end
end

exit(0)
