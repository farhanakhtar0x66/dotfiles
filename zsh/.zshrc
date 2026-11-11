# Environment & History
export HISTFILE="${ZDOTDIR:-$HOME/.config/zsh}/.zsh_history"
export HISTSIZE=10000
export SAVEHIST=10000
export SHELL_SESSIONS_DISABLE=1
export EDITOR='nvim'

# Autosuggestions Tuning
export ZSH_AUTOSUGGEST_MANUAL_REHASH=1
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
export ZSH_AUTOSUGGEST_USE_ASYNC=1

# XDG Paths
export NPM_CONFIG_USERCONFIG="$HOME/.config/npm/npmrc"
export NPM_CONFIG_CACHE="$HOME/.cache/npm"

# Oh My Zsh
export ZSH="$HOME/.config/oh-my-zsh"
export ZSH_COMPDUMP="$HOME/.cache/zcompdump"
export ZSH_CUSTOM="$ZSH/custom"
mkdir -p "$HOME/.cache"

zstyle ':omz:update' mode disabled
ZSH_THEME=""

plugins=(
  git
  sudo
  copypath
  copyfile
  zsh-autosuggestions
  zsh-syntax-highlighting
)

[[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# Aliases: Core & Neovim
alias vim='nvim'
alias vi='nvim'
alias cat='bat --paging=never --style=plain'
alias bcat='bat'
alias lg='lazygit'

# Aliases: eza
alias ls='eza --icons=always --group-directories-first'
alias l='eza -1 --icons=always --group-directories-first'
alias ll="eza -la --icons=always --group-directories-first --git --no-permissions --no-user --time-style=relative --ignore-glob='.DS_Store|.CFUserTextEncoding|.zshenv|.homebrew|.gemini'"
alias la='eza -la --icons=always --group-directories-first --git --time-style=relative'
alias lt='eza --tree --level=1 --icons=always'

# Aliases: Navigation & Shell
alias zshconfig="$EDITOR ${ZDOTDIR:-$HOME/.config/zsh}/.zshrc"
alias reload="source ${ZDOTDIR:-$HOME/.config/zsh}/.zshrc"
alias ..="cd .."
alias ...="cd ../.."

# Theming (GitHub Dark)
export BAT_THEME="GitHub Dark"
export FZF_DEFAULT_OPTS=" \
--color=bg+:#161b22,bg:#0d1117,spinner:#58a6ff,hl:#58a6ff \
--color=fg:#c9d1d9,header:#58a6ff,info:#bc8cff,pointer:#58a6ff \
--color=marker:#56d364,fg+:#f0f6fc,prompt:#58a6ff,hl+:#79c0ff"

# Integrations
eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

# Tmux Auto-start
if [[ -z "$TMUX" ]]; then
  exec tmux new-session -A -s main
fi

# Startup
fastfetch

# Created by `pipx` on 2026-10-02 13:55:38
export PATH="$PATH:/Users/farhanakhtar/.local/bin"
