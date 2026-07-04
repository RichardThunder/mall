# Dev container zsh profile, modeled after the local macOS shell without secrets.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="candy"

zstyle ':omz:update' mode disabled
DISABLE_AUTO_TITLE="true"

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt append_history
setopt share_history
setopt hist_ignore_dups
setopt hist_reduce_blanks

fpath+=${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}/plugins/zsh-completions/src
plugins=(
  git
  docker
  docker-compose
  mvn
  npm
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

export EDITOR="${EDITOR:-vim}"
export LANG="${LANG:-C.UTF-8}"
export LC_ALL="${LC_ALL:-C.UTF-8}"
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lh='ls -lh'
alias lha='ls -lha'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias c='clear'

alias mkdir='mkdir -pv'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

alias dfh='df -h'
alias duh='du -h'
alias dus='du -sh'
alias du1='du -h --max-depth=1'

alias grep='grep --color=auto'
alias rgf='rg --files'
alias hg='history | grep'

alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dv='docker volume ls'
alias dn='docker network ls'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcr='docker compose restart'
alias dcl='docker compose logs -f'
alias dcb='docker compose build'
alias dcp='docker compose ps'
alias dlogs='docker logs -f'
alias dexec='docker exec -it'
alias drm='docker rm'
alias drmi='docker rmi'
alias dprune='docker system prune -f'
alias dprunea='docker system prune -a -f --volumes'

alias codexyolo='codex --dangerously-bypass-approvals-and-sandbox'
alias yolo='claude --dangerously-skip-permissions'

[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
