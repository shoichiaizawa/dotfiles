#!/usr/bin/env bash
#
# Credits: name
#
# References:
# See: http://parkersamp.com/2010/10/howto-creating-a-dynamic-motd-in-linux/
# ASCII banner generator: http://patorjk.com/software/taag/

PROCCOUNT=`ps -Afl | wc -l`
PROCCOUNT=`expr $PROCCOUNT - 5`
SESSIONCOUNT=`who | grep -c $USER`
GROUPZ=`groups`

#if [ -x /usr/bin/tput ] && tput setaf 1 &> /dev/null; then
  #tput sgr0 # Reset colours
  #bold=$(tput bold)
  #reset=$(tput sgr0)

  ## Solarized colors
  ## (https://github.com/altercation/solarized/tree/master/iterm2-colors-solarized#the-values)
  #black=$(tput setaf 0)
  #blue=$(tput setaf 33)
  #cyan=$(tput setaf 37)
  #green=$(tput setaf 64)   # 190
  #orange=$(tput setaf 166) # 172
  #purple=$(tput setaf 125) # 141
  #red=$(tput setaf 124)
  #violet=$(tput setaf 61)
  #magenta=$(tput setaf 9)
  #white=$(tput setaf 15)   # 8
  #yellow=$(tput setaf 136)
#else
  #bold=""
  #reset="\e[0m"
  #black="\e[1;30m"
  #red="\e[1;31m"
  #green="\e[1;32m"
  #orange="\e[1;33m"
  #blue="\e[1;34m"
  #magenta="\e[1;35m"
  #violet="\e[1;35m"
  #purple="\e[1;35m"
  #cyan="\e[1;36m"
  #white="\e[1;37m"
#fi

echo "\033[1;32m

██╗  ██╗███████╗██╗     ██╗      ██████╗
██║  ██║██╔════╝██║     ██║     ██╔═══██╗
███████║█████╗  ██║     ██║     ██║   ██║
██╔══██║██╔══╝  ██║     ██║     ██║   ██║
██║  ██║███████╗███████╗███████╗╚██████╔╝▄█╗
╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝ ╚═════╝ ╚═╝

██╗   ██╗███╗   ██╗██╗██╗  ██╗    ██╗██╗██╗
██║   ██║████╗  ██║██║╚██╗██╔╝    ██║██║██║
██║   ██║██╔██╗ ██║██║ ╚███╔╝     ██║██║██║
██║   ██║██║╚██╗██║██║ ██╔██╗     ╚═╝╚═╝╚═╝
╚██████╔╝██║ ╚████║██║██╔╝ ██╗    ██╗██╗██╗
 ╚═════╝ ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝    ╚═╝╚═╝╚═╝

\033[1;33m+++++++++++++++++: \033[0;37mSystem Data\033[1;33m :+++++++++++++++++++
+  \033[0;37mHostname \033[1;33m= \033[1;32m`hostname`
\033[1;33m+    \033[0;37mKernel \033[1;33m= \033[1;32m`uname -srmp`
\033[1;33m+    \033[0;37mUptime \033[1;33m= \033[1;32m`uptime | sed -E 's/.*up ([^,]*), .*/\1/'`
\033[1;33m++++++++++++++++++: \033[0;37mUser Data\033[1;33m :++++++++++++++++++++
+  \033[0;37mUsername \033[1;33m= \033[1;32m`whoami`
\033[1;33m+  \033[0;37mSessions \033[1;33m= \033[1;32m$SESSIONCOUNT of $ENDSESSION MAX
\033[1;33m+ \033[0;37mProcesses \033[1;33m= \033[1;32m$PROCCOUNT of `ulimit -u 2>/dev/null` MAX
\033[1;33m+++++++++++++++++++++++++++++++++++++++++++++++++++
"
#cat /etc/motd

