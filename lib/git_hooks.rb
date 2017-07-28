
require 'fileutils'
require 'shellwords'

begin
  require 'term/ansicolor'
rescue LoadError
  # couldn't load up rubygems or term-ansicolor
end

module GitHooks
  COLOR_UI = `git config color.ui`.strip == 'true'

  if COLOR_UI && defined?(Term::ANSIColor)
    def msg(m, fg = nil, bg = nil)
      m = Term::ANSIColor.send(bg) { m } if bg
      m = Term::ANSIColor.send(fg) { m } if fg
    end
  else
    # A default msg method in case the term-ansicolor gem isn't installed...
    def msg(m, fg = nil, bg = nil)
      m
    end
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

  def shared_path(*args)
    File.join(File.dirname(__FILE__), *args)
  end

  def fetch_command(command_key, command_fallback = nil)
    command = GitHooks::GitUtils.git_config(:"#{command_key}-command")

    return command unless command.empty?

    return unless command_fallback

    command = which(command_fallback)

    puts "ERROR: Can't find #{command_fallback} on $PATH"
    exit(127)
  end

  def files_to_check
    `git rev-parse --verify HEAD`
    against = if $? == 0
      'HEAD'
    else
      '4b825dc642cb6eb9a060e54bf8d69288fbee4904'
    end

    `git diff-index #{COLOR_UI ? '--color' : ''} --check --cached #{against}`
  end

  def whoa_there
    "\n#{msg('/!\\', 'white', 'on_red')} #{msg('WHOA THERE', 'red')} #{msg('/!\\', 'white', 'on_red')}\n\n"
  end

  def ok
    "#{msg('OK!', 'green')}"
  end

  def running(command_name)
    msg("Running #{command_name}... ", 'yellow')
  end

  def checking_files(files)
    <<~TEXT
      Checking
        #{files.join("\n  ")}
    TEXT
  end

  def partially_staged_code(code_type, command)
    <<~TEXT
      ERROR: Looks like you've got partially staged #{code_type} code.

      Running #{command} on partially staged code could lead to inaccurate
      results. Please either stage the #{code_type} files directly or try
      running checkstyle on the #{code_type} files directly and if everything
      looks good you can commit using \`--no-verify\`.
    TEXT
  end

  def show_violations(violations)
    text = <<~TEXT
      Problems in commit! Take a gander at this:

    TEXT

    violations.relevant_violations.each do |file, violations|
      violations.each do |violation|
        text << <<~TEXT
          #{file}:#{violation.line_number}:#{violation.column_number}:#{violation.severity}: #{violation.message}
          \ \ #{violation.line_content}
        TEXT
      end
    end

    text
  end

  extend self
end
