My Bash dotfiles, managed with [chezmoi](https://www.chezmoi.io/), for macOS,
Linux, FreeBSD, and Termux.

- Sets `OS`, `DIST`, and tool paths without resetting the inherited PATH.
- Loads prompt and completion in interactive shells.
- Makes tool paths, including macOS `bearcli`, available to login-shell automation.

## Startup

Bash login shells load `.bash_profile` → `.profile` → `.bashrc`.
`.bashrc` loads the shared `.shell_env` and `.bash.d/*.sh` tool fragments.
Environment setup runs first; prompt and completion setup runs only in
interactive shells. Reopening or nesting a shell preserves existing PATH order.

To run a remote command with the configured environment:

```sh
ssh host 'bash -lc "command"'
```

## Tools

Bash completion loads when installed. direnv updates the environment as you
change directories. If pyenv is installed, it supplies Python shims; use a
version that supports `pyenv init - --no-push-path bash` so nested shells keep
an activated virtualenv's priority.

History keeps 50,000 entries in memory and 100,000 on disk, skipping commands
with a leading space and consecutive duplicates. Console prompts support color,
and `ls`/`grep` use color when available. Existing locale settings are preserved.

## SSH agent

Shells preserve agents supplied by the desktop or SSH forwarding. Otherwise,
they share an agent at `~/.ssh/agent.sock`, starting it when needed and retrying
a stale socket once. An agent with no keys is reused, and closing a shell
leaves the agent running.

SSH config gets an `AddKeysToAgent yes` default so keys are added when used.
Existing host settings are preserved and take precedence over this default.
