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
setopt histignoredups
setopt correct              
setopt no_correctall        
antidote load
ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd completion history)
# WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
alias ls='ls --color'
alias ll='ls -l'
alias ..="cd .."
# bindkey -e
bindkey "^[b" backward-word
bindkey "^[f" forward-word
bindkey "^[^[[C" forward-word
bindkey "^[^[[D" backward-word
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
. /nix/var/nix/profiles/default/etc/profile.d/nix.sh
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
export PATH=/Users/egoist/.local/bin:$PATH
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
