# ~/.profile: Executed by Bourne-compatible login SHells.
#
# Path to personal scripts and executables (~/.local/bin).
[ -d "$HOME/.local/bin" ] || mkdir -p "$HOME/.local/bin"
export PATH=$HOME/.local/bin:$PATH

ONDEMAND=/etc/sysconfig/tcedir/ondemand
[ -d "$ONDEMAND" ] && export PATH=$PATH:"$ONDEMAND"

# Environment variables and prompt for Ash SHell
# or Bash. Default is a classic prompt.
#
PS1='\u@\h:\w\$ '
PAGER='less -EM'
MANPAGER='less -isR'

EDITOR=vi

export PS1 PAGER FILEMGR EDITOR MANPAGER

export BACKUP=1
[ "`id -un`" = "`cat /etc/sysconfig/tcuser`" ] && echo "$BACKUP" | sudo tee /etc/sysconfig/backup >/dev/null 2>&1
export FLWM_TITLEBAR_COLOR="58:7D:AA"

if [ -f "$HOME/.ashrc" ]; then
   export ENV="$HOME/.ashrc"
   . "$HOME/.ashrc"
fi

TERMTYPE=`/usr/bin/tty`
[ ${TERMTYPE:5:3} == "tty" ] && (
[ ! -f /etc/sysconfig/Xserver ] ||
[ -f /etc/sysconfig/text ] ||
[ -e /tmp/.X11-unix/X0 ] || 
startx
)

for i in $(seq 1 99)
do
  ONLINE=$(ifconfig eth0 | grep -c 'inet')
  if [[ $ONLINE == 1 ]]
  then
    echo "Online!"
    break
  else
    echo "Waiting for eth0.. ($i/99)"
    usleep 1000000
  fi
done

echo My IP:
ifconfig eth0 | grep -B1 -w inet | awk '{print $1, $2}'
