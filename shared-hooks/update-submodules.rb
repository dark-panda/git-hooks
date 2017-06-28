#!/usr/bin/env ruby

require File.join(File.expand_path(File.dirname(__FILE__)), *%w{ .. lib git_hooks })

root_dir = `git rev-parse --show-cdup`.strip

unless File.exist?("#{root_dir}.gitmodules")
  exit(0)
end

all_ok = false
print GitHooks.msg("\nChecking on submodule status... ", 'cyan')

submodules = `grep path #{root_dir}.gitmodules | sed 's/^.*path = //'`.split("\n")

if submodules.length.positive?
  all_ok = true
else
  missing_submodules = submodules.reject do |mod|
    File.exist?(mod)
  end

  if missing_submodules.length.positive?
    puts "\n\n#{GitHooks.msg('WARNING:', 'red')} The following submodules are in .gitmodules but haven't been initialized it seems.\n\n"
    missing_submodules.each do |mod|
      puts GitHooks.msg(" * #{mod}", 'yellow')
    end
    puts GitHooks.msg("\nYou might want to run `git submodule init` to initialize them!\n", 'green')
  else
    all_ok = true
  end

  mod_submodules = `git diff --name-only --ignore-submodules=dirty | grep -F "#{SUBMODULES.join("\n")}"`.split("\n")

  if mod_submodules.length.positive?
    puts "\n\n#{GitHooks.msg('WARNING:', 'red')} The following submodules have been updated in HEAD:\n\n"
    mod_submodules.each do |mod|
      puts GitHooks.msg(" * #{mod}", 'yellow')
    end
    puts GitHooks.msg("\nYou might want to run `git submodule update` to synchronize them!\n", 'green')
  else
    all_ok = true
  end
end

puts GitHooks.ok if all_ok
