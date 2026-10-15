# Disable Homebrew analytics for interactive shells and scripts.
export HOMEBREW_NO_ANALYTICS=1

# Define the convenience function only in interactive macOS shells
# with Homebrew and the 1Password CLI available.
[[ $- == *i* ]] || return 0
[[ "$OSTYPE" == darwin* ]] || return 0
command -v brew >/dev/null 2>&1 || return 0
command -v op >/dev/null 2>&1 || return 0

brew() {
    if [[ "${1:-}" == search &&
          -z "${SSH_CONNECTION:-}" &&
          -z "${HOMEBREW_GITHUB_API_TOKEN:-}" ]]; then
        local token
        token=$(command op item get "Github/homebrew-api-token" \
            --fields label=password --reveal) || return

        HOMEBREW_GITHUB_API_TOKEN="$token" command brew "$@"
    else
        command brew "$@"
    fi
}
