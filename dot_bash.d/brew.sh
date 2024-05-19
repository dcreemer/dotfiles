# shellcheck disable=SC2155,SC2039
#
# Homebrew (mac, Linux)
#

# I wrap the brew command in a shell script elsewhere, I want to
# determine the brew prefix without calling the executable ("brew
# --prefix")

BREW=""

for b in /opt/homebrew /usr/local /home/linuxbrew/.linuxbrew; do
    if command -v "$b"/bin/brew > /dev/null; then
        BREW="$b"
        break
    fi
    # no brew on this system
done

if [ "$BREW" != "" ]; then
    # bash completion via Homebrew
    COMP="$BREW"/etc/profile.d/bash_completion.sh
    if [ -r "${COMP}" ]; then
        # shellcheck source=/dev/null
        . "${COMP}"
    fi

    # Turn off Homebrew analytics
    # https://github.com/Homebrew/brew/blob/master/share/doc/homebrew/Analytics.md
    export HOMEBREW_NO_ANALYTICS=1
fi
