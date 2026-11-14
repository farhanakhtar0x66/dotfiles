# ~/.config/zsh/.zshrc — plain zsh, no framework.
# Target: < 60ms to an interactive prompt. Profile with:  ZPROF=1 zsh -i -c exit

[[ -n $ZPROF ]] && zmodload zsh/zprof

# ── tmux: hand off BEFORE doing any work ──────────────────────────────────
# Only in Ghostty (not Zed / VS Code / ssh terminals), never nested.
if [[ -z $TMUX && $TERM_PROGRAM == ghostty ]] && (( $+commands[tmux] )); then
  exec tmux new-session -A -s main
fi

# Drop variables left in long-lived tmux servers by the previous setup.
unset STARSHIP_CONFIG BAT_THEME

# ── options & history ─────────────────────────────────────────────────────
HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt extended_history hist_ignore_all_dups hist_ignore_space \
       hist_reduce_blanks hist_verify share_history
setopt auto_cd auto_pushd pushd_ignore_dups pushd_silent \
       interactive_comments no_beep no_flow_control

: ${XDG_CACHE_HOME:=$HOME/.cache}
_zcache="$XDG_CACHE_HOME/zsh"
[[ -d $_zcache ]] || mkdir -p "$_zcache"

# ── completion (full rebuild at most once a day) ──────────────────────────
fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
autoload -Uz compinit
_zcd="$_zcache/zcompdump"
_stale=( $_zcd(N.mh+24) )
if [[ ! -s $_zcd || -n $_stale ]]; then
  compinit -i -d "$_zcd"
  { zcompile "$_zcd" } &!
else
  compinit -C -d "$_zcd"
fi
unset _stale

zmodload zsh/complist
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$_zcache/compcache"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}── %d%f'

# ── colors (Zacess High Contrast) ─────────────────────────────────────────
export CLICOLOR=1
export LS_COLORS='di=1;34:ln=35:so=31:pi=33:ex=1;32:bd=1;33:cd=1;33:su=1;31:sg=1;31:tw=1;34:ow=1;34'
export GREP_COLORS='mt=1;33'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
export FZF_DEFAULT_OPTS="--height=45% --layout=reverse --border=rounded --info=inline-right \
--color=bg:#000000,bg+:#0a2552,fg:#e0e0e0,fg+:#ffffff,hl:#f5c400,hl+:#ffe08a \
--color=border:#3a3a3a,header:#8fd0ff,info:#b3b3b3,marker:#26f444,pointer:#f5c400 \
--color=prompt:#8fd0ff,spinner:#f2a6ff,query:#ffffff,gutter:#000000"

# ── keys ──────────────────────────────────────────────────────────────────
bindkey -e
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search edit-command-line
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
zle -N edit-command-line
bindkey '^[[A' up-line-or-beginning-search   '^[OA' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search '^[OB' down-line-or-beginning-search
bindkey '^[[1;3D' backward-word  '^[[1;3C' forward-word   # alt-arrows
bindkey '^X^E' edit-command-line
bindkey -M menuselect '^[[Z' reverse-menu-complete

# Esc Esc → prefix the command with sudo (replaces the oh-my-zsh sudo plugin)
_sudo_toggle() {
  [[ -z $BUFFER ]] && BUFFER=$(fc -ln -1)
  if [[ $BUFFER == sudo\ * ]]; then BUFFER=${BUFFER#sudo }; else BUFFER="sudo $BUFFER"; fi
  CURSOR=${#BUFFER}
}
zle -N _sudo_toggle
bindkey '\e\e' _sudo_toggle

# ── tool init, cached (regenerated only when the binary is updated) ───────
_cached_init() {
  local name=$1 bin=${commands[$2]} out="$_zcache/$1.zsh"
  [[ -n $bin ]] || return 0
  if [[ ! -s $out || $bin -nt $out ]]; then
    "${@:2}" >| "$out" 2>/dev/null
  fi
  source "$out"
}
_cached_init starship starship init zsh --print-full-init
_cached_init zoxide   zoxide init zsh
_cached_init fzf      fzf --zsh

# ── plugins (brew first, old oh-my-zsh checkout as fallback) ──────────────
ZSH_AUTOSUGGEST_STRATEGY=(history)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=40
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_MANUAL_REHASH=1
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6e6e6e'
ZSH_HIGHLIGHT_MAXLENGTH=300
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

_source_first() { local f; for f; do [[ -r $f ]] && { source "$f"; return 0; }; done; return 1 }
_source_first /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
              $XDG_CONFIG_HOME/oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
# syntax highlighting must be sourced last
if _source_first /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
                 $XDG_CONFIG_HOME/oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; then
  typeset -A ZSH_HIGHLIGHT_STYLES
  ZSH_HIGHLIGHT_STYLES[command]='fg=#26f444'
  ZSH_HIGHLIGHT_STYLES[builtin]='fg=#26f444'
  ZSH_HIGHLIGHT_STYLES[alias]='fg=#26f444'
  ZSH_HIGHLIGHT_STYLES[function]='fg=#26f444'
  ZSH_HIGHLIGHT_STYLES[precommand]='fg=#26f444,underline'
  ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#ff9e94,bold'
  ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#f2a6ff'
  ZSH_HIGHLIGHT_STYLES[path]='fg=#8fd0ff,underline'
  ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#f5c400'
  ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#f5c400'
  ZSH_HIGHLIGHT_STYLES[comment]='fg=#7a7a7a'
  ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#00f4e0'
  ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#00f4e0'
fi
unfunction _source_first

# ── aliases ───────────────────────────────────────────────────────────────
alias ls='eza --group-directories-first --icons=auto'
alias l='ls -1'
alias ll='eza -l --group-directories-first --icons=auto --no-permissions --no-user --time-style=relative'
alias la='ll -a'
alias llg='ll -a --git'                  # git status column (slower in big repos)
alias lt='eza --tree --level=2 --icons=auto --git-ignore'
alias grep='grep --color=auto'
alias cat='bat --paging=never --style=plain'
alias vim='vis' vi='vis'
alias lg='lazygit'
alias y='yazi'
alias ff='fastfetch'
alias ..='cd ..' ...='cd ../..' ....='cd ../../..'
alias reload='exec zsh'
alias zshconfig="$EDITOR ${ZDOTDIR:-$HOME}/.zshrc"

# git (the handful of oh-my-zsh aliases worth keeping)
alias g='git' gs='git status -sb' ga='git add' gaa='git add -A' gc='git commit' gcm='git commit -m'
alias gco='git checkout' gsw='git switch' gb='git branch' gd='git diff' gds='git diff --staged'
alias gp='git push' gl='git pull' glog='git log --oneline --graph --decorate -20'

copypath() { print -rn -- "${${1:-.}:A}" | pbcopy && print "copied ${${1:-.}:A}"; }
copyfile() { [[ -f $1 ]] && pbcopy < "$1" && print "copied contents of $1"; }
mkcd()     { mkdir -p -- "$1" && cd -- "$1"; }

# ── greeting: fastfetch in the first pane of a tmux window only (splits stay fast) ──
if [[ -n $TMUX && -z $ZPROF ]] && (( $+commands[fastfetch] )); then
  [[ $(tmux display -p '#{window_panes}') == 1 ]] && fastfetch
fi

[[ -n $ZPROF ]] && zprof
