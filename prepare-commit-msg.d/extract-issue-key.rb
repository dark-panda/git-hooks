#!/usr/bin/env ruby

require File.join(File.expand_path(File.dirname(__FILE__)), *%w{ .. lib git_hooks })
require GitHooks.shared_path('git_hooks/git_tools')
require GitHooks.shared_path('git_hooks/git_utils')

commit_msg_file = ARGV[0]
issue_key_config = GitHooks::GitUtils.git_config('issue-key-pattern')
issue_key_regexp = Regexp.new(issue_key_config, Regexp::EXTENDED | Regexp::IGNORECASE)

if GitHooks::GitUtils.git_current_branch =~ issue_key_regexp
  original_commit_msg = File.read(commit_msg_file)
  issue_key = Regexp.last_match[:issue_key]

  unless original_commit_msg.lines[0] =~ /^(?<issue_key>app-\d+)/i
    File.open(commit_msg_file, 'w') do |fp|
      fp.puts("#{issue_key}  ".upcase)
      fp.write(original_commit_msg)
    end
  end
end
