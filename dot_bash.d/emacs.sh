# Emacs shortcuts belong only in interactive shells with Emacs installed.
[[ $- == *i* ]] || return 0
command -v emacs >/dev/null 2>&1 || return 0

if command -v emacsclient >/dev/null 2>&1; then
    alias ec='emacsclient'
fi

# Remove the old alias when reloading this fragment in an existing shell.
unalias ff 2>/dev/null || :

ff() {
    local gui=no

    # SSH wins even when X forwarding supplies DISPLAY.
    if [[ -z ${SSH_CONNECTION:-} && -z ${SSH_CLIENT:-} && -z ${SSH_TTY:-} ]]; then
        case "$OSTYPE" in
            darwin*)
                # A logged-in desktop user owns /dev/console on macOS.
                if [[ $(stat -f %u /dev/console 2>/dev/null) == "$UID" && $UID != 0 ]]; then
                    gui=yes
                fi
                ;;
            *)
                if [[ -n ${DISPLAY:-} || -n ${WAYLAND_DISPLAY:-} ]]; then
                    gui=yes
                fi
                ;;
        esac
    fi

    if [[ $gui == no ]]; then
        command emacs -nw "$@"
        return $?
    fi

    # Disable the client's fallback so a missing server launches a normal app.
    if command -v emacsclient >/dev/null 2>&1 &&
        command emacsclient --no-wait --alternate-editor=false "$@" 2>/dev/null; then
        return 0
    fi

    command emacs "$@" &
}
