My Bash dotfiles, managed with [chezmoi](https://www.chezmoi.io/), for macOS,
Linux, FreeBSD, and Termux.

- Sets `OS`, `DIST`, and tool paths without resetting the inherited PATH.
- Loads prompt and completion in interactive shells.
- Makes tool paths, including macOS `bearcli`, available to login-shell automation.

## Install

Run as your normal user with `curl` and internet access. Linux and FreeBSD need
working `sudo`; macOS needs an administrator account. On Android, run inside
Termux. Supported systems are Apple Silicon macOS, Arch, Debian/Ubuntu and
compatible derivatives, FreeBSD, and Termux.

The example uses your local `$USER` as the GitHub username. Change
`GITHUB_USERNAME` if the account containing your `dotfiles` repository differs.

```sh
GITHUB_USERNAME="$USER"
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- \
  -b "$HOME/.local/bin" init --apply "$GITHUB_USERNAME"
```

This installs chezmoi in `~/.local/bin`, applies the dotfiles, installs common
CLI tools, and selects Bash 5+ as your login shell. It asks for your email,
profile (`basic`/`full`), location, and any required passwords. macOS installs
Homebrew if needed and keeps the profile/location-specific extras.

Arch and Termux perform a full package upgrade before installing tools.
Installers run again when their contents change. Restart your sessions after
installation: log out and back in (or reboot), and end old tmux servers.

## Sync

Edit the source with `chezmoi edit ~/.bashrc` (or edit this repository), review
with `chezmoi diff`, then run `chezmoi apply`. Commit and push the source changes
with Git. On other devices, run `chezmoi update` to pull and apply them.

If you edited a destination file directly, capture it with `chezmoi add` or
`chezmoi merge` before committing.

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
and `ls`/`grep` use color when available. Working UTF-8 locale settings are
preserved; other settings get an available UTF-8 fallback. Linux generates a
locale during installation if needed. Termux uses its UTF-8 default.

## SSH agent

Shells preserve agents supplied by the desktop or SSH forwarding. Otherwise,
they share an agent at `~/.ssh/agent.sock`, starting it when needed and retrying
a stale socket once. An agent with no keys is reused, and closing a shell
leaves the agent running.

SSH config gets an `AddKeysToAgent yes` default so keys are added when used.
Existing host settings are preserved and take precedence over this default.
