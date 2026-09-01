#!/usr/bin/env bash
# arxos-greeter installer.
# Installs the ARXOS login screen. It is ONE greeter that is:
#   - the login screen (LightDM display manager), and
#   - the lock screen (light-locker locks the session back to this greeter), and
#   - the system default login for every user (live, installer-created, and later users).
# The greeter is an HTML theme rendered by web-greeter (the maintained HTML greeter).
# It replaces the old lightdm-webkit2-greeter, which does not build on current Arch.
# Idempotent. Run as root.
set -euo pipefail

log(){ printf '\033[1;33m>> %s\033[0m\n' "$*"; }
HERE="$(cd "$(dirname "$0")" && pwd)"
[ "$(id -u)" = 0 ] || { echo "run as root (sudo bash install.sh)"; exit 1; }

log "packages (LightDM + lock + web-greeter runtime deps)"
# xcb-util-cursor is REQUIRED: web-greeter is a Qt6 app and its xcb platform plugin
# needs libxcb-cursor, or the greeter aborts and LightDM fails to start.
pacman -S --noconfirm --needed lightdm light-locker xcb-util-cursor xorg-xsetroot qt6-wayland

log "web-greeter engine (AUR)"
if ! pacman -Q web-greeter >/dev/null 2>&1; then
  if command -v arx >/dev/null 2>&1; then arx install web-greeter || true
  elif command -v yay >/dev/null 2>&1; then sudo -u "${SUDO_USER:-nobody}" yay -S --noconfirm web-greeter || true
  fi
fi
pacman -Q web-greeter >/dev/null 2>&1 || { echo "!! web-greeter is not installed. Install it (AUR: web-greeter) then re-run."; exit 1; }

log "greeter background (readable by the greeter)"
install -d /usr/share/backgrounds/arxos
BG=/usr/share/backgrounds/arxos/arxos-login.png
if [ -f "$HERE/data/arxos-login.png" ]; then install -m644 "$HERE/data/arxos-login.png" "$BG"
elif [ -f "$BG" ]; then chmod 644 "$BG"
else
  SRC=$(ls /usr/share/backgrounds/arxos/*.png 2>/dev/null | grep -v '/arxos-login\.png$' | head -1 || true)
  [ -n "$SRC" ] && install -m644 "$SRC" "$BG" || BG=""
fi

log "install the ARXOS HTML theme"
install -d /usr/share/web-greeter/themes
rm -rf /usr/share/web-greeter/themes/arxos
cp -rfT "$HERE/data/webkit-theme/arxos" /usr/share/web-greeter/themes/arxos
[ -n "$BG" ] && cp -f "$BG" /usr/share/web-greeter/themes/arxos/bg.png || true

log "point web-greeter at the arxos theme"
CFG=/etc/lightdm/web-greeter.toml
if [ -f "$CFG" ]; then
  grep -q '^theme' "$CFG" && sed -i 's|^theme.*|theme = "arxos"|' "$CFG" || sed -i '1a theme = "arxos"' "$CFG"
else
  printf '[greeter]\ntheme = "arxos"\n' > "$CFG"
fi

log "make web-greeter the LightDM default (no autologin on the shipped system)"
install -d /etc/lightdm/lightdm.conf.d
printf '[Seat:*]\ngreeter-session=web-greeter\nuser-session=xfce\n' > /etc/lightdm/lightdm.conf.d/10-arxos.conf

log "lock screen == this greeter, for every user (system autostart + skel)"
install -Dm644 "$HERE/data/autostart/light-locker.desktop" /etc/xdg/autostart/light-locker.desktop
install -Dm644 "$HERE/data/autostart/light-locker.desktop" /etc/skel/.config/autostart/light-locker.desktop

log "enable LightDM as the display manager"
systemctl enable lightdm

echo ">> arxos-greeter installed. web-greeter shows the ARXOS HTML login, the lock screen, and the default login."
echo ">> apply now with: systemctl restart lightdm  (this ends the current graphical session)"
