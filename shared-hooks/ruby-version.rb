#!/usr/bin/env ruby

require(File.join(File.expand_path(File.dirname(__FILE__)), *%w{ .. lib git_hooks }))

ROOT_DIR=`git rev-parse --show-cdup`.strip

if !File.exist?("#{ROOT_DIR}.ruby-version") && !File.exist?("#{ROOT_DIR}bin/ruby-version")
  exit(0)
end

print GitHooks.msg("\nUpdating Ruby version... ", 'cyan')
ruby_version = `#{ROOT_DIR}bin/ruby-version`

if $? != 0
  puts "#{GitHooks.msg("WARNING:", 'red')} tried to switch Ruby versions but..."
  puts ruby_version
else
  puts GitHooks.ok
end
