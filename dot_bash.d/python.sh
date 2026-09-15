# uv manages Python by default; use pyenv when it is installed.
export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
for dir in "$PYENV_ROOT/bin" "$PYENV_ROOT/shims"; do
    [[ -d "$dir" ]] || continue
    case ":${PATH:-}:" in
        *":$dir:"*) ;;
        *) export PATH="$dir${PATH:+:$PATH}" ;;
    esac
done
unset dir

[[ $- == *i* ]] || return
if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init - --no-push-path bash)"
fi
