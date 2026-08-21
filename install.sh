#!/usr/bin/env bash
#
# Dotfiles Installation & Management Script
# Designed for macOS (Darwin) with XDG-compliant path symlinking.
#

set -euo pipefail

# ------------------------------------------------------------------------------
# Platform Guard
# ------------------------------------------------------------------------------
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Error: This dotfiles installer only supports macOS (Darwin)." >&2
  exit 1
fi

# ------------------------------------------------------------------------------
# Constants & Colors
# ------------------------------------------------------------------------------
COLOR_RESET="\033[0m"
COLOR_BOLD="\033[1m"
COLOR_INFO="\033[1;34m"
COLOR_SUCCESS="\033[1;32m"
COLOR_WARN="\033[1;33m"
COLOR_ERROR="\033[1;31m"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
TIMESTAMP="$(date +"%Y%m%d_%H%M%S")"
BACKUP_BASE="$HOME/.dotfiles-backup"
BACKUP_DIR="$BACKUP_BASE/$TIMESTAMP"

# ------------------------------------------------------------------------------
# Logging Helpers
# ------------------------------------------------------------------------------
info() {
  printf "${COLOR_INFO}[INFO]${COLOR_RESET} %s\n" "$*"
}

success() {
  printf "${COLOR_SUCCESS}[SUCCESS]${COLOR_RESET} %s\n" "$*"
}

warn() {
  printf "${COLOR_WARN}[WARN]${COLOR_RESET} %s\n" "$*"
}

error() {
  printf "${COLOR_ERROR}[ERROR]${COLOR_RESET} %s\n" "$*" >&2
}

# ------------------------------------------------------------------------------
# Backup Function
# ------------------------------------------------------------------------------
backup_item() {
  local target="$1"
  if [[ -e "$target" || -L "$target" ]]; then
    local rel_path
    if [[ "$target" == "$HOME/"* ]]; then
      rel_path="${target#$HOME/}"
    else
      rel_path="$(basename "$target")"
    fi
    local dest="$BACKUP_DIR/$rel_path"
    mkdir -p "$(dirname "$dest")"
    mv "$target" "$dest"
    info "Backed up: $target -> $dest"
  fi
}

# ------------------------------------------------------------------------------
# Symlink Helper (Idempotent)
# ------------------------------------------------------------------------------
symlink_item() {
  local source="$1"
  local target="$2"

  if [[ ! -e "$source" ]]; then
    warn "Source $source does not exist, skipping."
    return 0
  fi

  # Check if already correctly symlinked
  if [[ -L "$target" ]]; then
    local current_dest
    current_dest="$(readlink "$target" || true)"
    if [[ "$current_dest" == "$source" ]]; then
      success "Already linked: $target -> $source"
      return 0
    fi
  fi

  # If target exists and is not the correct symlink, back it up
  if [[ -e "$target" || -L "$target" ]]; then
    backup_item "$target"
  fi

  mkdir -p "$(dirname "$target")"
  ln -sf "$source" "$target"
  success "Linked: $target -> $source"
}

# ------------------------------------------------------------------------------
# Homebrew & Package Management
# ------------------------------------------------------------------------------
ensure_homebrew() {
  if ! command -v brew &>/dev/null; then
    info "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ -f /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  else
    success "Homebrew is installed."
  fi
}

install_packages() {
  info "Checking and installing required Homebrew packages..."

  local FORMULAE=(
    "FelixKratz/formulae/sketchybar"
    "FelixKratz/formulae/borders"
    "starship"
    "fastfetch"
    "tmux"
    "nowplaying-cli"
    "eza"
    "fzf"
    "zoxide"
    "bat"
    "lazygit"
    "neovim"
  )

  local CASKS=(
    "nikitabobko/tap/aerospace"
    "ghostty"
    "font-jetbrains-mono-nerd-font"
    "font-sketchybar-app-font"
  )

  local installed_formulae
  installed_formulae="$(brew list --formula -1 2>/dev/null || true)"
  local installed_casks
  installed_casks="$(brew list --cask -1 2>/dev/null || true)"

  for formula in "${FORMULAE[@]}"; do
    local base_name
    base_name="$(basename "$formula")"
    if echo "$installed_formulae" | grep -qx "$base_name" || echo "$installed_formulae" | grep -qx "$formula"; then
      success "Formula '$formula' is already installed."
    else
      info "Installing formula '$formula'..."
      brew install "$formula" || warn "Failed to install $formula, continuing..."
    fi
  done

  for cask in "${CASKS[@]}"; do
    local base_cask
    base_cask="$(basename "$cask")"
    if echo "$installed_casks" | grep -qx "$base_cask" || echo "$installed_casks" | grep -qx "$cask"; then
      success "Cask '$cask' is already installed."
    else
      info "Installing cask '$cask'..."
      brew install --cask "$cask" || warn "Failed to install cask $cask, continuing..."
    fi
  done
}

# ------------------------------------------------------------------------------
# Zsh Environment Setup
# ------------------------------------------------------------------------------
setup_zshenv() {
  local zshenv="$HOME/.zshenv"
  local target_line='export ZDOTDIR="$HOME/.config/zsh"'

  if [[ -f "$zshenv" ]]; then
    if grep -Fxq "$target_line" "$zshenv"; then
      success "Already configured: $zshenv"
      return 0
    else
      backup_item "$zshenv"
      echo "$target_line" > "$zshenv"
      success "Configured: $zshenv"
    fi
  elif [[ -L "$zshenv" ]]; then
    backup_item "$zshenv"
    echo "$target_line" > "$zshenv"
    success "Configured: $zshenv"
  else
    echo "$target_line" > "$zshenv"
    success "Created: $zshenv"
  fi
}

# ------------------------------------------------------------------------------
# Oh My Zsh Setup (Dependencies for .zshrc plugins)
# ------------------------------------------------------------------------------
setup_zsh_framework() {
  local omz_dir="$CONFIG_DIR/oh-my-zsh"
  if [[ ! -d "$omz_dir" ]]; then
    info "Installing Oh My Zsh into $omz_dir..."
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$omz_dir" 2>/dev/null || true
  fi

  local plugins_dir="$omz_dir/custom/plugins"
  mkdir -p "$plugins_dir"

  if [[ ! -d "$plugins_dir/zsh-autosuggestions" ]]; then
    info "Cloning zsh-autosuggestions plugin..."
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git "$plugins_dir/zsh-autosuggestions" 2>/dev/null || true
  fi

  if [[ ! -d "$plugins_dir/zsh-syntax-highlighting" ]]; then
    info "Cloning zsh-syntax-highlighting plugin..."
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$plugins_dir/zsh-syntax-highlighting" 2>/dev/null || true
  fi
}

# ------------------------------------------------------------------------------
# Tmux & TPM Setup
# ------------------------------------------------------------------------------
setup_tmux_plugins() {
  local repo_tpm="$REPO_DIR/tmux/plugins/tpm"
  local target_tpm="$CONFIG_DIR/tmux/plugins/tpm"

  info "Configuring Tmux and TPM plugins..."

  # Clone TPM to repo if missing
  if [[ ! -d "$repo_tpm" ]]; then
    info "Cloning TPM to $repo_tpm..."
    mkdir -p "$(dirname "$repo_tpm")"
    git clone https://github.com/tmux-plugins/tpm "$repo_tpm"
    success "Cloned TPM to repo."
  else
    success "TPM is already present in repo at $repo_tpm."
  fi

  # Ensure target ~/.config/tmux/plugins/tpm is populated
  if [[ ! -d "$target_tpm" ]]; then
    info "Populating TPM to $target_tpm..."
    mkdir -p "$(dirname "$target_tpm")"
    cp -R "$repo_tpm" "$target_tpm"
    success "TPM installed to $target_tpm."
  else
    success "TPM is already installed at $target_tpm."
  fi

  # Run TPM plugin installation step to repopulate plugins
  local installer=""
  if [[ -x "$target_tpm/bin/install_plugins" ]]; then
    installer="$target_tpm/bin/install_plugins"
  elif [[ -x "$target_tpm/bindings/install_plugins" ]]; then
    installer="$target_tpm/bindings/install_plugins"
  elif [[ -x "$repo_tpm/bin/install_plugins" ]]; then
    installer="$repo_tpm/bin/install_plugins"
  elif [[ -x "$repo_tpm/bindings/install_plugins" ]]; then
    installer="$repo_tpm/bindings/install_plugins"
  fi

  if [[ -n "$installer" ]]; then
    info "Running TPM install_plugins ($installer)..."
    TMUX_PLUGIN_MANAGER_PATH="$CONFIG_DIR/tmux/plugins" "$installer" 2>/dev/null || true
    success "Tmux plugins repopulated via TPM."
  else
    warn "TPM install_plugins script not found; plugins can be installed in tmux with Prefix + I."
  fi
}

# ------------------------------------------------------------------------------
# Symlink Dotfiles
# ------------------------------------------------------------------------------
setup_symlinks() {
  info "Configuring configuration symlinks..."

  # 1. AeroSpace
  symlink_item "$REPO_DIR/aerospace/aerospace.toml" "$CONFIG_DIR/aerospace/aerospace.toml"

  # 2. Fastfetch
  symlink_item "$REPO_DIR/fastfetch" "$CONFIG_DIR/fastfetch"

  # 3. Ghostty
  symlink_item "$REPO_DIR/ghostty/config.ghostty" "$CONFIG_DIR/ghostty/config"

  # 4. SketchyBar
  symlink_item "$REPO_DIR/sketchybar" "$CONFIG_DIR/sketchybar"

  # 5. Starship
  symlink_item "$REPO_DIR/starship.toml" "$CONFIG_DIR/starship.toml"

  # 6. Tmux
  symlink_item "$REPO_DIR/tmux/tmux.conf" "$CONFIG_DIR/tmux/tmux.conf"

  # 7. Zsh configuration files
  mkdir -p "$CONFIG_DIR/zsh"
  for f in "$REPO_DIR"/zsh/.*; do
    local bname
    bname="$(basename "$f")"
    if [[ "$bname" == "." || "$bname" == ".." || "$bname" == ".git" || "$bname" == ".zsh_history" ]]; then
      continue
    fi
    symlink_item "$f" "$CONFIG_DIR/zsh/$bname"
  done
  for f in "$REPO_DIR"/zsh/*; do
    if [[ -e "$f" ]]; then
      local bname
      bname="$(basename "$f")"
      symlink_item "$f" "$CONFIG_DIR/zsh/$bname"
    fi
  done

  # 8. ~/.zshenv
  setup_zshenv
}

# ------------------------------------------------------------------------------
# Script Permissions
# ------------------------------------------------------------------------------
fix_permissions() {
  info "Ensuring all shell scripts in repo are executable..."
  find "$REPO_DIR" -type f -name "*.sh" -exec chmod +x {} +
  success "Script permissions verified."
}

# ------------------------------------------------------------------------------
# Uninstall Action
# ------------------------------------------------------------------------------
uninstall_dotfiles() {
  info "Starting dotfiles uninstallation..."

  local targets=(
    "$CONFIG_DIR/aerospace/aerospace.toml"
    "$CONFIG_DIR/fastfetch"
    "$CONFIG_DIR/ghostty/config"
    "$CONFIG_DIR/sketchybar"
    "$CONFIG_DIR/starship.toml"
    "$CONFIG_DIR/tmux/tmux.conf"
  )

  for f in "$REPO_DIR"/zsh/.*; do
    local bname
    bname="$(basename "$f")"
    if [[ "$bname" != "." && "$bname" != ".." && "$bname" != ".git" && "$bname" != ".zsh_history" ]]; then
      targets+=("$CONFIG_DIR/zsh/$bname")
    fi
  done
  for f in "$REPO_DIR"/zsh/*; do
    if [[ -e "$f" ]]; then
      targets+=("$CONFIG_DIR/zsh/$(basename "$f")")
    fi
  done

  # Remove symlinks pointing to this repo
  for target in "${targets[@]}"; do
    if [[ -L "$target" ]]; then
      local link_dest
      link_dest="$(readlink "$target" || true)"
      if [[ "$link_dest" == "$REPO_DIR"* ]]; then
        rm "$target"
        info "Removed symlink: $target"
      fi
    fi
  done

  # Clean up empty directory structures
  for d in "$CONFIG_DIR/aerospace" "$CONFIG_DIR/ghostty" "$CONFIG_DIR/zsh"; do
    if [[ -d "$d" ]] && [[ -z "$(ls -A "$d" 2>/dev/null)" ]]; then
      rmdir "$d" 2>/dev/null || true
    fi
  done

  # Revert ~/.zshenv if managed by dotfiles
  local zshenv="$HOME/.zshenv"
  if [[ -f "$zshenv" ]]; then
    if [[ "$(cat "$zshenv")" == 'export ZDOTDIR="$HOME/.config/zsh"' ]]; then
      rm "$zshenv"
      info "Removed: $zshenv"
    fi
  fi

  # Restore latest backup if available
  if [[ -d "$BACKUP_BASE" ]]; then
    local latest_backup
    latest_backup="$(find "$BACKUP_BASE" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort -r | head -n 1)"
    if [[ -n "$latest_backup" && -d "$latest_backup" ]]; then
      info "Restoring backup from $latest_backup..."
      cp -R "$latest_backup/." "$HOME/"
      rm -rf "$latest_backup"
      success "Backup restored from $latest_backup."
      
      # Clean up backup base if empty
      if [[ -z "$(ls -A "$BACKUP_BASE" 2>/dev/null)" ]]; then
        rmdir "$BACKUP_BASE" 2>/dev/null || true
      fi
    else
      info "No backup found to restore."
    fi
  fi

  success "Dotfiles uninstalled cleanly."
}

# ------------------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------------------
print_summary() {
  echo ""
  printf "${COLOR_BOLD}${COLOR_SUCCESS}======================================================${COLOR_RESET}\n"
  printf "${COLOR_BOLD}${COLOR_SUCCESS}   Dotfiles Installation & Linking Complete! 🎉       ${COLOR_RESET}\n"
  printf "${COLOR_BOLD}${COLOR_SUCCESS}======================================================${COLOR_RESET}\n"
  echo ""
  echo "Symlinked configurations:"
  echo "  • AeroSpace    -> ~/.config/aerospace/aerospace.toml"
  echo "  • Fastfetch    -> ~/.config/fastfetch/"
  echo "  • Ghostty      -> ~/.config/ghostty/config"
  echo "  • SketchyBar   -> ~/.config/sketchybar/"
  echo "  • Starship     -> ~/.config/starship.toml"
  echo "  • Tmux & TPM   -> ~/.config/tmux/tmux.conf"
  echo "  • Zsh & Env    -> ~/.config/zsh/ & ~/.zshenv"
  echo ""
  echo "Next steps:"
  echo "  1. Restart your terminal or reload Zsh:"
  echo "     source ~/.config/zsh/.zshrc"
  echo "  2. Relaunch / reload window manager & bar:"
  echo "     sketchybar --reload"
  echo "     aerospace reload-config"
  echo "  3. Start tmux:"
  echo "     tmux new -A -s main"
  echo ""
}

# ------------------------------------------------------------------------------
# Main Dispatch
# ------------------------------------------------------------------------------
main() {
  if [[ $# -gt 0 ]]; then
    case "${1:-}" in
      --uninstall|-u)
        uninstall_dotfiles
        exit 0
        ;;
      --help|-h)
        echo "Usage: ./install.sh [options]"
        echo ""
        echo "Options:"
        echo "  --uninstall, -u   Remove symlinks and restore most recent backup"
        echo "  --help, -h        Show this help message"
        exit 0
        ;;
      *)
        error "Unknown option: $1"
        echo "Run ./install.sh --help for usage."
        exit 1
        ;;
    esac
  fi

  info "Starting dotfiles installation..."
  fix_permissions
  ensure_homebrew
  install_packages
  setup_symlinks
  setup_zsh_framework
  setup_tmux_plugins

  # If backup directory was created but left empty, remove it
  if [[ -d "$BACKUP_DIR" ]] && [[ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]]; then
    rmdir "$BACKUP_DIR" 2>/dev/null || true
    rmdir "$BACKUP_BASE" 2>/dev/null || true
  fi

  print_summary
}

main "$@"
