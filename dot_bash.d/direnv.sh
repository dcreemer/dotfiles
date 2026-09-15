# Initialize once; some direnv versions duplicate array-valued prompt hooks.
[[ $- == *i* ]] || return 0
if ! declare -F _direnv_hook >/dev/null && command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook bash)"
fi
