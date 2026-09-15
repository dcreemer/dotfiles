# Rust executable paths are also needed by noninteractive login shells.
for dir in "$HOME/.cargo/bin" /opt/homebrew/opt/rustup/bin; do
    [[ -d "$dir" ]] || continue
    case ":${PATH:-}:" in
        *":$dir:"*) ;;
        *) export PATH="$dir${PATH:+:$PATH}" ;;
    esac
done
unset dir
