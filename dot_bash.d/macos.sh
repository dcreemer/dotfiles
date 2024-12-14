# shellcheck disable=SC2155,SC2039
#
# macOS specific
#

if [ "$OS" == "Darwin" ]; then

   # start ssh-agent
   pgrep ssh-agent > /dev/null
   if [ $? -ne 0 ]; then
       eval `ssh-agent -s`
   fi

fi
