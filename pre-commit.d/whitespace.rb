#!/usr/bin/env ruby

require(File.join(File.expand_path(File.dirname(__FILE__)), *%w{ .. lib git_hooks }))
require GitHooks.shared_path('git_hooks/git_tools')

puts GitHooks.running('whitespace')

files = GitHooks.files_to_check

unless $? == 0
  puts GitHooks.whoa_there
  puts "#{GitHooks.msg('Whitespace', 'black', 'on_white')} problems in commit! Take a gander at this:\n\n"
  puts "#{files}\n\n"
  exit(1)
end

puts GitHooks.ok
exit(0)
