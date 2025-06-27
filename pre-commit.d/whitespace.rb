#!/usr/bin/env ruby

require 'json'
require(File.join(File.expand_path(File.dirname(__FILE__)), *%w{ .. lib git_hooks }))
require GitHooks.shared_path('git_hooks/git_tools')

puts GitHooks.running('whitespace')

`git rev-parse --verify HEAD`

against = if $? == 0
  'HEAD'
else
  '4b825dc642cb6eb9a060e54bf8d69288fbee4904'
end

files = `git diff-index #{GitHooks::COLOR_UI ? '--color' : ''} --check --cached #{against}`

ignores = GitHooks.ignores('whitespace')
checks = []
lines = files.lines

lines.each_with_index do |line, index|
  if index.even?
    file = line.split(':')[0]

    next if ignores.include?(file)

    checks << line
    checks << lines[index + 1]
  end
end

if !checks.empty?
  puts GitHooks.whoa_there
  puts "#{GitHooks.msg('Whitespace', 'black', 'on_white')} problems in commit! Take a gander at this:\n\n"
  puts "#{checks.join("\n")}\n\n"
  exit(1)
end

puts GitHooks.ok
exit(0)
