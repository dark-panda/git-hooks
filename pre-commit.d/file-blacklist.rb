#!/usr/bin/env ruby

require File.join(File.expand_path(File.dirname(__FILE__)), *%w{ .. lib git_hooks })
require GitHooks.shared_path('git_hooks/git_tools')
require GitHooks.shared_path('git_hooks/git_utils')

statuses, files = GitHooks::GitUtils.git_statuses_and_files

if !files.empty?
  puts <<~TEXT
    #{GitHooks.running('blacklist checker')}

    #{GitHooks.checking_files(files)}
  TEXT

  if File.exist?('.gitblacklist')
    blacklisted_files = files & File.read('.gitblacklist').lines.collect(&:strip)

    if !blacklisted_files.empty?
      puts GitHooks.whoa_there
      puts "Some blacklisted files were found in this commit. Take a look at:\n\n"

      blacklisted_files.each do |file|
        puts "  - #{file}"
      end

      puts

      exit(100)
    end
  end

  puts GitHooks.ok
end

exit(0)
