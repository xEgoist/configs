# clone antidote if necessary
[[ -e ~/.antidote ]] || git clone https://github.com/mattmc3/antidote.git ~/.antidote

# source antidote
. ~/.antidote/antidote.zsh

# generate and source plugins from ~/.zsh_plugins.txt
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

export HISTFILESIZE=1000000000
export HISTSIZE=1000000000
export HISTFILE=~/.zsh_history
export SAVEHIST=1000000000
setopt INC_APPEND_HISTORY

setopt histignoredups
setopt correct              
setopt no_correctall        



antidote load
ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd completion history)
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
alias ls='ls --color'
alias ll='ls -l'
alias ..="cd .."
bindkey -e
# bindkey "^[b" backward-word
# bindkey "^[f" forward-word
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
# . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
# . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

export PATH=$HOME/.local/bin:$PATH

export PATH=/home/egoist/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin:$PATH
source "$(fzf-share)/key-bindings.zsh"
source "$(fzf-share)/completion.zsh"
alias nix-shell="nix-shell --run zsh"
alias open="xdg-open"
[ "$(tty)" = "/dev/tty1" ] && exec sway