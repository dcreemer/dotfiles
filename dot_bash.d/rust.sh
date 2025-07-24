# shellcheck disable=SC2155
#
# rust:
#

for b in ${HOME}/.cargo/bin /opt/homebrew/opt/rustup/bin; do
    if [ -e "${b}" ]; then
        export PATH="${b}:$PATH"
    fi
done
