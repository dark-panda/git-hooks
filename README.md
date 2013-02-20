
# J's Git Hooks

This is just a small collection of git hooks that I like to use along with
a simple infrastructure for enabling and disabling them.

## Creating Hooks

To create a new hook:

1. create a directory for the hook based on the hook event name (i.e. a
  `post-checkout` hook would go into a `post-checkout.d` directory).

2. set up a symlink from the `shared-hook` script to the hook event name.

3. place your hook into the hook directory and make sure it's executable.

## Enabling and Disabling Hooks

Hooks can be enabled and disabled either by setting the executable bit on the
hooks themselves and by using your git config to enable the infrastructure
itself.

In your git config files, you can enable the master hook event using the
following configuration settings:

```
[hooks "hook-event-name"]
  enabled = true
```

This enables the actual event itself, i.e. `post-checkout`. You can then
enable or disable individual hook scripts thusly:

```
[hooks "post-checkout"]
  enabled = true
  update-submodules-rb = true
```

The `update-submodules-rb` line enables the `post-checkout.d/update-submodules.rb`
script. Script names are munged to replace any `.` characters with `-`
characters so as to not act wonky with git's configuration parser.

## License

This collection of git hooks and the infrastructure and all that is covered
under the MIT license. See the `MIT-LICENSE` file for details.

