#!/usr/bin/env ruby

require_relative(File.join(*%w{ .. lib shared }))

ROOT_DIR=`git rev-parse --show-cdup`.strip

if !File.exists?("#{ROOT_DIR}.gitmodules")
  exit(0)
end

all_ok = false
print msg("\nChecking on submodule status... ", 'cyan')

SUBMODULES=`grep path #{ROOT_DIR}.gitmodules | sed 's/^.*path = //'`.split("\n")

unless SUBMODULES.length <= 0
  all_ok = true
else
  missing_submodules = SUBMODULES.select do |mod|
    !File.exists?(mod)
  end

  if missing_submodules.length > 0
    puts "\n\n#{msg("WARNING:", 'red')} The following submodules are in .gitmodules but haven't been initialized it seems.\n\n"
    missing_submodules.each do |mod|
      puts msg(" * #{mod}", 'yellow')
    end
    puts msg("\nYou might want to run `git submodule init` to initialize them!\n", 'green')
  else
    all_ok = true
  end

  MOD_SUBMODULES=`git diff --name-only --ignore-submodules=dirty | grep -F "#{SUBMODULES.join("\n")}"`.split("\n")

  if MOD_SUBMODULES.length > 0
    puts "\n\n#{msg("WARNING:", 'red')} The following submodules have been updated in HEAD:\n\n"
    MOD_SUBMODULES.each do |mod|
      puts msg(" * #{mod}", 'yellow')
    end
    puts msg("\nYou might want to run `git submodule update` to synchronize them!\n", 'green')
  else
    all_ok = true
  end
end

if all_ok
  puts msg('OK', 'green')
end


