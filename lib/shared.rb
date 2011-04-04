
COLOR_UI = `git config color.ui`.strip == 'true'

# A default msg method in case the term-ansicolor gem isn't installed...
def msg(m, fg = nil, bg = nil)
  m
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

