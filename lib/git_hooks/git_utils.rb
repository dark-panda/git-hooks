
module GitHooks
  module GitUtils
    def hook_type
      ENV['HOOK_TYPE']
    end

    def hook_name
      ENV['HOOK_NAME']
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

    def git_base_path
      `git rev-parse --show-toplevel`.strip
    end

    extend self
  end
end
