My current set of dotfiles. Uses [Chezmoi](https://github.com/twpayne/chezmoi) for
installation and management.

This configuration is designed to use the
[Bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell)) shell on Mac OS, Linux,
and similar environments like WSL and [Termux](https://termux.com/). It sets up
a consistent environment general CLI usage and development.

Some features:

- Sets a few extra environment variables, such as `OS` and `DIST`
- Ensures the `ssh-agent` is properly running and terminated as appropriate
