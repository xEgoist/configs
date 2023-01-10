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

setopt correctall
antidote load
ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd completion history)
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
alias ls='ls --color'
alias ll='ls -l'
bindkey -e
bindkey "^[b" backward-word
bindkey "^[f" forward-word
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
#. /nix/var/nix/profiles/default/etc/profile.d/nix.sh
#. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
export PATH=/home/egoist/.local/bin:$PATH
export PATH=/opt/wasi-sdk/bin:$PATH
export HISTFILE=~/.zsh_history
export HISTSIZE=100000
export SAVEHIST=$HISTSIZE
alias open=xdg-open
if [ -n "${commands[fzf-share]}" ]; then
  source "$(fzf-share)/key-bindings.zsh"
  source "$(fzf-share)/completion.zsh"
fi
#[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

[ "$(tty)" = "/dev/tty1" ] && exec sway
