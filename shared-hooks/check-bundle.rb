#!/usr/bin/env ruby

require(File.join(File.expand_path(File.dirname(__FILE__)), *%w{ .. lib git_hooks }))

ROOT_DIR=`git rev-parse --show-cdup`.strip

if !File.exist?("#{ROOT_DIR}Gemfile")
  exit(0)
end

if !File.exist?("#{ROOT_DIR}Gemfile.lock")
  puts GitHooks.msg("\nYou have a Gemfile but no Gemfile.lock, so you may want to do a `bundle install`.\n")
  exit(0)
 end

print GitHooks.msg("\nChecking on bundle status... ", 'cyan')

bundle_list = `bundle list`

if $? != 0
  puts "#{GitHooks.msg("WARNING:", 'red')} bundler doesn't like your current bundle set up. Here's the error message it returned:\n\n"
  puts bundle_list
else
  puts GitHooks.ok
end
