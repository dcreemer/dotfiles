#!/usr/bin/env bash

NEWVERS="$1"
CURVERS=$(python -V | cut -d " " -f 2)

pyenv install --list | grep -q "$NEWVERS"
if [ $? -ne 0 ]; then
    echo "$NEWVERS not found"
    exit 1
fi

echo "Upgrade from $CURVERS to $NEWVERS ?"
[[ "$(read -r -e -p 'Continue? [y/N]> '; echo $REPLY)" == [Yy]* ]] || exit 1

set -e

OPTS=""
if [ $OS == "Darwin" ]; then
    OPTS="--enable-framework"
    exit 1
fi

env PYTHON_CONFIGURE_OPTS="${OPTS}" pyenv install -v "$NEWVERS"
pyenv global "$NEWVERS"
python -m pip install -U pip --force-reinstall
python -m pip install -U pipx
pipx reinstall-all
