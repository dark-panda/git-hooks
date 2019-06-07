#!/usr/bin/env ruby

require File.join(File.expand_path(File.dirname(__FILE__)), *%w{ .. lib git_hooks })
require GitHooks.shared_path('git_hooks/git_tools')
require GitHooks.shared_path('git_hooks/git_utils')
require GitHooks.shared_path('git_hooks/haml_lint')

statuses, files = GitHooks::GitUtils.git_statuses_and_files(/(.+(?:\.(?:haml)))/)

if !files.empty?
  if statuses.include?('AM')
    puts GitHooks.partially_staged_code('Haml', 'haml-lint')
    exit(127)
  else
    haml_lint = GitHooks.fetch_command('haml-lint', 'haml-lint')

    puts <<~TEXT
      #{GitHooks.running('haml-lint')}

      #{GitHooks.checking_files(files)}
    TEXT

    cmd = "#{haml_lint} --reporter json #{files.collect { |file|
      Shellwords.escape(file)
    }.join(' ')}"

    output = `#{cmd}`

    if $? != 0
      diffs = GitHooks::GitTools::Diff.new(GitHooks::GitUtils.git_diff(:cached))
      violations = GitHooks::HamlLint::Violations.new(output, diffs)

      if violations.relevant_violations?
        puts GitHooks.whoa_there
        puts GitHooks.show_violations(violations)
        exit(1)
      end
    end

    puts GitHooks.ok
  end
end

exit(0)
