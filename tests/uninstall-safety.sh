#!/usr/bin/env bash
set -euo pipefail
repo=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export HOME="$tmp/home" XDG_CONFIG_HOME="$tmp/home/.config"
mkdir -p "$HOME/.dotfiles-backup/20260101_000000/.config/aerospace" "$XDG_CONFIG_HOME/aerospace"
printf 'original\n' > "$HOME/.dotfiles-backup/20260101_000000/.config/aerospace/aerospace.toml"
printf 'new user data\n' > "$XDG_CONFIG_HOME/aerospace/aerospace.toml"
"$repo/install.sh" --uninstall >/dev/null
[[ $(cat "$XDG_CONFIG_HOME/aerospace/aerospace.toml") == 'new user data' ]] || { echo 'uninstall overwrote user data' >&2; exit 1; }
[[ -f "$HOME/.dotfiles-backup/20260101_000000/.config/aerospace/aerospace.toml" ]] || { echo 'uninstall discarded backup' >&2; exit 1; }
echo 'uninstall preserves conflicting files and backups'
mkdir -p "$XDG_CONFIG_HOME/ghostty" "$HOME/.dotfiles-backup/20260101_000000/.config/ghostty"
printf 'old ghostty\n' > "$HOME/.dotfiles-backup/20260101_000000/.config/ghostty/config"
ln -s "${repo}-unrelated/config" "$XDG_CONFIG_HOME/ghostty/config"
"$repo/install.sh" --uninstall >/dev/null
[[ -L "$XDG_CONFIG_HOME/ghostty/config" ]] || { echo 'uninstall removed an unrelated symlink sharing a path prefix' >&2; exit 1; }
[[ -f "$HOME/.dotfiles-backup/20260101_000000/.config/ghostty/config" ]] || { echo 'uninstall lost backup behind unrelated symlink' >&2; exit 1; }
echo 'uninstall preserves unrelated symlinks'
