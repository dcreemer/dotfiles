# shellcheck disable=SC2039
#
# Termux (Android) specific
#

if [ "$DIST" == "termux" ]; then

    # start ssh-agent if needed
    start_ssh_agent

fi
