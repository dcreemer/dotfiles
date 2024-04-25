# shellcheck disable=SC2155,SC2039
#
# Homebrew (mac, linux)
#

if command -v brew > /dev/null; then

    # bash completion via homebrew
    COMP="$(brew --prefix)"/etc/profile.d/bash_completion.sh
    if [ -r "${COMP}" ]; then
        # shellcheck source=/dev/null
        . "${COMP}"
    fi

    # Turn off homebrew analytics
    # https://github.com/Homebrew/brew/blob/master/share/doc/homebrew/Analytics.md
    export HOMEBREW_NO_ANALYTICS=1

    # if not on remote machine
    if [ -z "$SSH_CLIENT" ] && command -v op > /dev/null; then
        # github personal access token
        # see https://github.com/settings/tokens
        export HOMEBREW_GITHUB_API_TOKEN=$(op item get "Github/homebrew-api-token" --fields label=password)
    fi

fi
