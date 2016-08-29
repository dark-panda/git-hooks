#!/usr/bin/env ruby

require 'pathname'
require(File.join(Pathname.new(File.dirname(__FILE__)).realpath, *%w{ .. lib shared }))

ROOT_DIR=`git rev-parse --show-cdup`.strip

if !File.exists?("#{ROOT_DIR}Gemfile")
  exit(0)
end

if !File.exists?("#{ROOT_DIR}Gemfile.lock")
  puts msg("\nYou have a Gemfile but no Gemfile.lock, so you may want to do a `bundle install`.\n")
  exit(0)
 end

print msg("\nChecking on bundle status... ", 'cyan')

bundle_list = `bundle list`

if $? != 0
  puts "#{msg("WARNING:", 'red')} bundler doesn't like your current bundle set up. Here's the error message it returned:\n\n"
  puts bundle_list
else
  puts msg('OK', 'green')
end

