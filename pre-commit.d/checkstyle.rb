#!/usr/bin/env ruby

require File.join(File.expand_path(File.dirname(__FILE__)), *%w{ .. lib git_hooks })
require GitHooks.shared_path('git_hooks/git_tools')
require GitHooks.shared_path('git_hooks/git_utils')
require GitHooks.shared_path('git_hooks/checkstyle')

checkstyle = GitHooks.fetch_command('checkstyle', 'checkstyle')
statuses, files = GitHooks::GitUtils.git_statuses_and_files(/(.+(?:\.(?:java)))/)

if !files.empty?
  if statuses.include?('AM')
    puts GitHooks.partially_staged_code('Java')
    exit(127)
  else
    puts <<~TEXT
      #{GitHooks.running('checkstyle')}

      #{GitHooks.checking_files(files)}
    TEXT

    cmd = "#{checkstyle} -f xml #{files.collect { |file|
      Shellwords.escape(file)
    }.join(' ')}"

    output = `#{cmd}`

    diffs = GitHooks::GitTools::Diff.new(GitHooks::GitUtils.git_diff(:cached))
    violations = GitHooks::Checkstyle::Violations.new(output, diffs)

    if violations.relevant_violations?
      puts GitHooks.whoa_there
      puts GitHooks.show_violations(violations)

      exit(1)
    end

    puts GitHooks.ok
  end
end

exit(0)
