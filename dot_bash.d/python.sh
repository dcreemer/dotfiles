# shellcheck disable=SC2155,SC2039
#
# python
#

# I use uv to install, choose, and run python runtimes and tools
if command -v uv 1>/dev/null 2>&1; then
    alias python="uv run python3"
    alias python3="uv run python3"
else
    # check for (older) pyenv and pipx
    PYENV_ROOT="$HOME/.pyenv"
    if [ -d "$PYENV_ROOT" ]; then
        export PYENV_ROOT
        export PATH="$PYENV_ROOT/bin:$PATH"
    fi

    if command -v pyenv 1>/dev/null 2>&1; then
        eval "$(pyenv init --path)"
        eval "$(pyenv init -)"
    fi

    if command -v pipx 1>/dev/null 2>&1; then
        eval "$(register-python-argcomplete pipx)"
    fi
fi
