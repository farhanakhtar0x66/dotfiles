# ~/.config/zsh/.zprofile — login-shell environment (runs once per login shell)

# Homebrew — static equivalent of `brew shellenv`, saves a ~20ms subprocess.
export HOMEBREW_PREFIX=/opt/homebrew
export HOMEBREW_CELLAR=/opt/homebrew/Cellar
export HOMEBREW_REPOSITORY=/opt/homebrew
export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:"
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"

typeset -U path fpath
path=(
  $HOME/.local/bin
  /opt/homebrew/bin
  /opt/homebrew/sbin
  $path
)

# XDG base directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export EZA_CONFIG_DIR="$XDG_CONFIG_HOME/eza"

export EDITOR=vis           # built from source against Lua 5.4 (see install.sh)
export VISUAL=vis
export PAGER=less
export LESS='-R -F -i -M'
export SHELL_SESSIONS_DISABLE=1
# Homebrew: skip the auto-update that runs before every install/upgrade (run `brew update` yourself)
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1
