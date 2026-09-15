# Bear's CLI is also used by automation and inherited non-login scripts.
if [[ ${OS:-} == Darwin && -x /Applications/Bear.app/Contents/MacOS/bearcli ]]; then
    case ":${PATH:-}:" in
        *:/Applications/Bear.app/Contents/MacOS:*) ;;
        *) export PATH="/Applications/Bear.app/Contents/MacOS${PATH:+:$PATH}" ;;
    esac

    [[ $- == *i* ]] || return 0
    eval "$(/Applications/Bear.app/Contents/MacOS/bearcli --generate-completion-script bash)"
fi
