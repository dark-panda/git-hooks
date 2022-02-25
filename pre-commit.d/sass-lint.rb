#!/usr/bin/env ruby

require File.join(File.expand_path(File.dirname(__FILE__)), *%w{ .. lib git_hooks })
require GitHooks.shared_path('git_hooks/git_tools')
require GitHooks.shared_path('git_hooks/git_utils')
require GitHooks.shared_path('git_hooks/sass_lint')

statuses, files = GitHooks::GitUtils.git_statuses_and_files(/(.+(?:\.(?:sass|scss)))/)

if !files.empty?
  if statuses.include?('AM')
    puts GitHooks.partially_staged_code('Sass', 'sass-lint')
    exit(127)
  else
    sass_lint = GitHooks.fetch_command('sass-lint', 'sass-lint')

    puts <<~TEXT
      #{GitHooks.running('sass-lint')}

      #{GitHooks.checking_files(files)}
    TEXT

    outputs = []
    exit_statuses = []
    files.each { |file|
      cmd = "#{sass_lint} --verbose --format json #{Shellwords.escape(file)}"
      outputs << `#{cmd}`
      exit_statuses << $?
    }

    has_errors = !exit_statuses.map(&:to_i).all?(&:zero?)
    should_exit = false

    if !outputs.empty?
      outputs.each do |output|
        next if output.empty?

        diffs = GitHooks::GitTools::Diff.new(GitHooks::GitUtils.git_diff(:cached))
        violations = GitHooks::SassLint::Violations.new(output, diffs)

        if violations.relevant_violations?
          puts GitHooks.whoa_there
          puts GitHooks.show_violations(violations)
          should_exit = true
        end
      end

      if should_exit
        exit(1)
      end
    end

    puts GitHooks.ok
  end
end

exit(0)
