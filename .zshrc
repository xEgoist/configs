
# Set the name of the static .zsh plugins file antidote will generate.
zsh_plugins=${ZDOTDIR:-~}/.zsh_plugins.zsh

# Ensure you have a .zsh_plugins.txt file where you can add plugins.
[[ -f ${zsh_plugins:r}.txt ]] || touch ${zsh_plugins:r}.txt

# Lazy-load antidote.
fpath+=(${ZDOTDIR:-~}/.antidote)
autoload -Uz $fpath[-1]/antidote

# Generate static file in a subshell when .zsh_plugins.txt is updated.
if [[ ! $zsh_plugins -nt ${zsh_plugins:r}.txt ]]; then
  (antidote bundle <${zsh_plugins:r}.txt >|$zsh_plugins)
fi

# Source your static plugins file.
source $zsh_plugins


export HISTFILESIZE=1000000000
export HISTSIZE=1000000000
export HISTFILE=~/.zsh_history
export SAVEHIST=1000000000
setopt INC_APPEND_HISTORY

setopt histignoredups
setopt correct
setopt no_correctall



# antidote load
ZSH_AUTOSUGGEST_STRATEGY=(history match_prev_cmd completion )
WORDCHARS='*?-[]~&;!#$%^'
alias ls='ls --color'
alias ll='ls -l'
alias ..="cd .."
bindkey -e
# bindkey "^[b" backward-word
# bindkey "^[f" forward-word
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

function set_default_opts(){
  WIDTHVAR=$(($COLUMNS/2))
  HEIGHTVAR=$(($LINES/2))
  zstyle ':fzf-tab:*' fzf-pad $HEIGHTVAR
  export FZF_DEFAULT_OPTS="
  --color=fg:#707a8c,bg:-1,hl:#3e9831,fg+:#cbccc6,bg+:#0e1419,hl+:#5fff87 \
  --color=dark \
  --color=info:#af87ff,prompt:#5fff87,pointer:#ff87d7,marker:#ff87d7,spinner:#ff87d7 \
  --sort \
  --layout=reverse \
  --preview-window=right:$WIDTHVAR
  --bind '?:toggle-preview' \
  --cycle \
  "
}

set_default_opts
# export FZF_DEFAULT_OPTS='--cycle --layout=reverse --border --height=90% --preview-window=wrap --marker="*"'

# export FZF_DEFAULT_OPTS='--height 100% --layout=reverse --border'
zstyle ':completion:*' menu select

# . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
# . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

export PATH=$HOME/.local/bin:$PATH
PS1='%F{blue}%~ %(?.%F{green}.%F{red})|%f '
eval "$(direnv hook zsh)"

source "$(fzf-share)/key-bindings.zsh"
source "$(fzf-share)/completion.zsh"
alias open="xdg-open"
alias code="codium"
[ "$(tty)" = "/dev/tty1" ] && exec sway

