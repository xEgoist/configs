LOGNAME=$(logname)
HOSTNAME=$(hostname)
PS1='$(printf "\e[37m%s:\e[34m%s\e[4m%s\e[m~> " \
  "$LOGNAME@$HOSTNAME" "$PWD" )'
HISTFILE="$HOME/.ksh_history"
HISTSIZE=5000
set -o emacs
alias __A=$(print '\0020') # ^P = up = previous command
alias __B=$(print '\0016') # ^N = down = next command
alias __C=$(print '\0006') # ^F = right = forward a character
alias __D=$(print '\0002') # ^B = left = back a character
alias __H=$(print '\0001') # ^A = home = beginning of line
