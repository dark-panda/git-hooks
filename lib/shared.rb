
require 'fileutils'
require 'shellwords'

COLOR_UI = `git config color.ui`.strip == 'true'

# A default msg method in case the term-ansicolor gem isn't installed...
def msg(m, fg = nil, bg = nil)
  m
end

def which(name)
  found = false

  paths = ENV["PATH"].split(File::PATH_SEPARATOR)
  paths.unshift("#{FileUtils.pwd}/bin")

  paths.each do |path|
    file = File.join(path, name)

    if File.executable?(file)
      return file
    end
  end

  false
end

def hook_type
  ENV['HOOK_TYPE']
end

def hook_name
  ENV['HOOK_NAME']
end

def shared_path(*args)
  File.join(File.dirname(__FILE__), *args)
end

def git_statuses_and_files(*file_patterns)
  file_patterns_regexp = if !file_patterns.empty?
    /#{file_patterns.join('|')}/
  else
    /.+/
  end

  status = `git status --porcelain`
  statuses_and_files = status.scan(/^([AM]+)\s+(#{file_patterns_regexp})$/)

  [ statuses_and_files.collect(&:first), statuses_and_files.collect(&:last) ]
end

def git_diff(cached = false)
  if cached
    `git diff --cached`
  else
    `git diff`
  end
end

def git_config(key)
  `git config hooks.#{hook_type}.#{hook_name}.#{key}`.strip
end

if COLOR_UI
  begin
    require 'rubygems'
    require 'term/ansicolor'

    def msg(m, fg = nil, bg = nil)
      m = Term::ANSIColor.send(bg) { m } if bg
      m = Term::ANSIColor.send(fg) { m } if fg
    end
  rescue LoadError
    # couldn't load up rubygems or term-ansicolor
  end
end

