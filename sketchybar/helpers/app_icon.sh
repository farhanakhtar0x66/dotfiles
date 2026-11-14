#!/bin/zsh
# app_icon "App Name"  →  sets $REPLY to a sketchybar-app-font ligature, e.g. ":ghostty:".
# Fork-free: names resolve against the font's glyph list (app_glyphs.txt);
# only names that don't slugify cleanly need an entry below.
typeset -g _APP_GLYPHS=" ${(j: :)${(f)"$(<${${(%):-%x}:A:h}/app_glyphs.txt)"}} "

app_icon() {
  case "$1" in
    "System Settings"|"System Preferences") REPLY=":gear:"; return ;;
    "Code"|"Visual Studio Code"|"VSCodium")  REPLY=":code:"; return ;;
    "WhatsApp")                              REPLY=":whats_app:"; return ;;
    "Bitwarden")                             REPLY=":bit_warden:"; return ;;
    "ChatGPT")                               REPLY=":openai:"; return ;;
    "1Password"*)                            REPLY=":one_password:"; return ;;
    "Zen"|"Zen Browser")                     REPLY=":zen_browser:"; return ;;
    "Microsoft PowerPoint")                  REPLY=":microsoft_power_point:"; return ;;
  esac
  local slug=${${(L)1}//[ .-]/_}
  if [[ $_APP_GLYPHS == *" $slug "* ]]; then REPLY=":$slug:"; else REPLY=":default:"; fi
}
