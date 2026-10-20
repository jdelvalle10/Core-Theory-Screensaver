#!/usr/bin/env bash
# Removes the Core Theory display for the current user.
set -uo pipefail
for BASE in "$HOME/snap/firefox/common/core-theory" "$HOME/.local/share/core-theory"; do
  [[ -d "$BASE" ]] && rm -rf "$BASE" && echo "Removed $BASE"
done
rm -f "$HOME/.local/share/applications/core-theory.desktop"
DESK="$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Desktop")"
rm -f "$DESK/core-theory.desktop"
if command -v gsettings >/dev/null 2>&1; then
  CUR="$(gsettings get org.gnome.shell favorite-apps 2>/dev/null || echo "")"
  if [[ "$CUR" == *"core-theory.desktop"* ]]; then
    NEW="$(python3 -c 'import ast,sys; l=ast.literal_eval(sys.argv[1].replace("@as ","")); print(str([a for a in l if a!="core-theory.desktop"]))' "$CUR")"
    gsettings set org.gnome.shell favorite-apps "$NEW"
  fi
fi
echo "Core Theory display removed."
