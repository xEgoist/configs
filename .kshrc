LOGNAME=$(logname)
HOSTNAME=$(hostname)
PS1="${LOGNAME}@${HOSTNAME}:\[\033[00;34m\]\${PWD} \[\033[00;00m\]~> "
HISTFILE="$HOME/.ksh_history"
HISTSIZE=5000
set -o emacs
alias ls='ls --color=auto'
[ "$(tty)" = "/dev/tty1" ] && exec sway
