# Load bash-completion once per interactive shell.
[[ $- == *i* ]] || return 0
[[ -n ${BASH_COMPLETION_VERSINFO:-} ]] && return 0

# Homebrew, FreeBSD, and Linux package entry points; no fragment-order dependency.
completion_files=(
    "${HOMEBREW_PREFIX:-/opt/homebrew}/etc/profile.d/bash_completion.sh"
    /home/linuxbrew/.linuxbrew/etc/profile.d/bash_completion.sh
    /usr/local/share/bash-completion/bash_completion
    /usr/share/bash-completion/bash_completion
    /etc/bash_completion
)
case "${PREFIX:-}" in
    /*) completion_files=("$PREFIX/share/bash-completion/bash_completion" "${completion_files[@]}") ;;
esac
for completion_file in "${completion_files[@]}"; do
    [[ -f "$completion_file" && -r "$completion_file" ]] || continue
    # shellcheck source=/dev/null
    source "$completion_file"
    break
done
unset completion_file completion_files
