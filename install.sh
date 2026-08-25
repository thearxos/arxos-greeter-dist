#!/usr/bin/env bash
# arxos-greeter installer.
# Installs the ARXOS login screen. It is ONE greeter that is:
#   - the login screen (LightDM display manager), and
#   - the lock screen (light-locker locks the session back to this greeter), and
#   - the system default login for every user (live, installer-created, and later users).
# It replaces the old webkit greeter, which failed logins. This one uses the stable
# lightdm-gtk-greeter, themed for ARXOS. Idempotent. Run as root.
set -euo pipefail

log(){ printf '\033[1;33m>> %s\033[0m\n' "$*"; }
HERE="$(cd "$(dirname "$0")" && pwd)"
[ "$(id -u)" = 0 ] || { echo "run as root (sudo bash install.sh)"; exit 1; }

log "packages"
pacman -S --noconfirm --needed lightdm lightdm-gtk-greeter light-locker

log "greeter background (system path, readable by the lightdm user)"
install -d /usr/share/backgrounds/arxos
BG=/usr/share/backgrounds/arxos/arxos-login.png
if [ -f "$HERE/data/arxos-login.png" ]; then
  install -m644 "$HERE/data/arxos-login.png" "$BG"
elif [ -f "$BG" ]; then
  chmod 644 "$BG"   # already in place from a prior run
else
  # use any other ARXOS wallpaper, but never copy the target onto itself
  SRC=$(ls /usr/share/backgrounds/arxos/*.png 2>/dev/null | grep -v '/arxos-login\.png$' | head -1 || true)
  if [ -n "$SRC" ]; then install -m644 "$SRC" "$BG"; else BG=""; fi
fi

log "greeter config"
install -Dm644 "$HERE/data/lightdm-gtk-greeter.conf" /etc/lightdm/lightdm-gtk-greeter.conf
# kora icons are optional; fall back to Adwaita if they are not present
[ -d /usr/share/icons/kora ] || sed -i 's/^icon-theme-name = kora/icon-theme-name = Adwaita/' /etc/lightdm/lightdm-gtk-greeter.conf
# no background image found -> use a solid ARXOS-dark colour instead of a missing file
if [ -z "$BG" ]; then
  sed -i 's|^background = .*|background = #0a0a0c|' /etc/lightdm/lightdm-gtk-greeter.conf
fi

log "make this greeter the LightDM default (no autologin on the shipped system)"
install -d /etc/lightdm/lightdm.conf.d
cat > /etc/lightdm/lightdm.conf.d/10-arxos.conf <<'SEAT'
[Seat:*]
greeter-session=lightdm-gtk-greeter
SEAT

log "lock screen == this greeter, for every user (system autostart + skel)"
install -Dm644 "$HERE/data/autostart/light-locker.desktop" /etc/xdg/autostart/light-locker.desktop
install -Dm644 "$HERE/data/autostart/light-locker.desktop" /etc/skel/.config/autostart/light-locker.desktop

log "enable LightDM as the display manager"
systemctl enable lightdm

echo ">> arxos-greeter installed. LightDM is the login screen, the lock screen, and the default login."
echo ">> apply now with: systemctl restart lightdm  (this ends the current graphical session)"
