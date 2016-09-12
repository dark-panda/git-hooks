#!/usr/bin/env ruby

require(File.join(File.expand_path(File.dirname(__FILE__)), *%w{ .. lib shared }))

`git rev-parse --verify HEAD`
against = if $? == 0
  'HEAD'
else
  '4b825dc642cb6eb9a060e54bf8d69288fbee4904'
end

puts msg('Running whitespace checks... ', 'yellow')

files = `git diff-index #{COLOR_UI ? '--color' : ''} --check --cached #{against}`
unless $? == 0
  puts "#{msg('/!\\', 'white', 'on_red')} #{msg('WHOA THERE', 'red')}, #{msg('/!\\', 'white', 'on_red')}\n\n"
  puts "#{msg('Whitespace', 'black', 'on_white')} problems in commit! Take a gander at this:\n\n"
  puts "#{files}\n\n"
  exit(1)
end

puts "\n#{msg('OK!', 'green')}"
exit(0)
