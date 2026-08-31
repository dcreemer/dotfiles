# shellcheck disable=SC2039
#
# Arch Linux specific
#

if [ "$DIST" == "Arch" ]; then

    # start ssh-agent if needed
    start_ssh_agent

fi
