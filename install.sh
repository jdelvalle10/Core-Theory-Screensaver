#!/usr/bin/env bash
# Core Theory display — installer for Ubuntu (GNOME, X11 or Wayland) with Firefox.
# Installs for the CURRENT user only; no sudo needed.
# Usage:  bash install.sh            (adds a launcher icon to the app grid, dock and desktop)
#         bash install.sh --no-dock  (skip adding it to the dock)
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ADD_DOCK=1
[[ "${1:-}" == "--no-dock" ]] && ADD_DOCK=0

command -v firefox >/dev/null 2>&1 || { echo "Firefox not found. Install it first."; exit 1; }

# Ubuntu ships Firefox as a snap; a snap can only read hidden folders inside its own area,
# so the files go where Firefox is allowed to open them.
if snap list firefox >/dev/null 2>&1; then
  BASE="$HOME/snap/firefox/common/core-theory"
  echo "Firefox: snap package"
else
  BASE="$HOME/.local/share/core-theory"
  echo "Firefox: regular package"
fi

mkdir -p "$BASE/profile"
install -m 644 "$SRC/core-theory.html" "$BASE/core-theory.html"
install -m 644 "$SRC/icon.svg" "$BASE/icon.svg"

# Dedicated, quiet Firefox profile (does not touch your normal Firefox profile).
cat > "$BASE/profile/user.js" <<'EOF'
user_pref("dom.allow_scripts_to_close_windows", true);
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("browser.aboutwelcome.enabled", false);
user_pref("browser.startup.homepage_override.mstone", "ignore");
user_pref("startup.homepage_welcome_url", "");
user_pref("startup.homepage_welcome_url.additional", "");
user_pref("datareporting.policy.dataSubmissionPolicyBypassNotification", true);
user_pref("datareporting.policy.firstRunURL", "");
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("toolkit.telemetry.enabled", false);
user_pref("app.normandy.enabled", false);
user_pref("browser.sessionstore.resume_from_crash", false);
user_pref("browser.tabs.warnOnClose", false);
user_pref("browser.translations.automaticallyPopup", false);
user_pref("full-screen-api.warning.timeout", 0);
EOF

# Launcher script
cat > "$BASE/launch.sh" <<EOF
#!/usr/bin/env bash
# Starts the Core Theory display full screen. Touch the board or press any key to exit.
BASE="$BASE"
URL="file://\$BASE/core-theory.html?kiosk=1"
# Keep the screen from blanking while it plays.
if command -v gnome-session-inhibit >/dev/null 2>&1; then
  exec gnome-session-inhibit --inhibit idle --reason "Core Theory display" \\
    firefox --no-remote --profile "\$BASE/profile" --kiosk "\$URL"
else
  exec firefox --no-remote --profile "\$BASE/profile" --kiosk "\$URL"
fi
EOF
chmod 755 "$BASE/launch.sh"

# App-grid entry
APPS="$HOME/.local/share/applications"
mkdir -p "$APPS"
cat > "$APPS/core-theory.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Core Theory
Comment=Animated Core Theory equation (classroom display)
Exec=$BASE/launch.sh
Icon=$BASE/icon.svg
Terminal=false
Categories=Education;Science;
StartupNotify=false
EOF
chmod 644 "$APPS/core-theory.desktop"
command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$APPS" >/dev/null 2>&1 || true

# Desktop icon (Ubuntu needs it marked trusted to launch on double-tap)
DESK="$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Desktop")"
if [[ -d "$DESK" ]]; then
  install -m 755 "$APPS/core-theory.desktop" "$DESK/core-theory.desktop"
  gio set "$DESK/core-theory.desktop" metadata::trusted true 2>/dev/null || true
fi

# Dock favorite
if [[ $ADD_DOCK -eq 1 ]] && command -v gsettings >/dev/null 2>&1; then
  CUR="$(gsettings get org.gnome.shell favorite-apps 2>/dev/null || echo "")"
  if [[ -n "$CUR" && "$CUR" != *"core-theory.desktop"* ]]; then
    NEW="$(python3 -c 'import ast,sys; l=ast.literal_eval(sys.argv[1].replace("@as ","")); l.append("core-theory.desktop"); print(str(l))' "$CUR")"
    gsettings set org.gnome.shell favorite-apps "$NEW" || true
  fi
fi

echo
echo "Installed to: $BASE"
echo "Start it from the dock, the app grid (search 'Core Theory'), or the desktop icon."
echo "Touch the board or press any key to exit."
