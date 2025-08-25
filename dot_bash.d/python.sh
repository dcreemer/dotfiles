# shellcheck disable=SC2155,SC2039
#
# python
#

# I use uv to install, choose, and run python runtimes and tools, however,
# if pyenv is installed, that will take precedence:

PYENV_ROOT="$HOME/.pyenv"
if [ -d "$PYENV_ROOT" ]; then
    export PYENV_ROOT
    export PATH="$PYENV_ROOT/bin:$PATH"
fi

if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
fi
