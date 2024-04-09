# shellcheck disable=SC2155,SC2039
#
# python
#

# use pyenv to choose and switch python interpreters
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
