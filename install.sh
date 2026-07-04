#!/usr/bin/env bash
# ArxOS Greeter - installer for the LightDM webkit greeter theme + the welcome splash.
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
echo ":: installing the ArxOS webkit greeter theme"
sudo install -Dm644 "$DIR/themes/arxos/index.html"  /usr/share/lightdm-webkit/themes/arxos/index.html
sudo install -Dm644 "$DIR/themes/arxos/index.theme" /usr/share/lightdm-webkit/themes/arxos/index.theme
echo ":: installing the welcome splash"
sudo install -Dm755 "$DIR/arxos-welcome" /usr/local/bin/arxos-welcome
echo ":: pointing LightDM at the webkit greeter + the arxos theme"
[ -f /etc/lightdm/lightdm-webkit2-greeter.conf ] && sudo sed -i 's/^webkit_theme.*/webkit_theme        = arxos/' /etc/lightdm/lightdm-webkit2-greeter.conf
[ -f /etc/lightdm/lightdm.conf ] && sudo sed -i 's/^#*greeter-session=.*/greeter-session=lightdm-webkit2-greeter/' /etc/lightdm/lightdm.conf
echo ":: autostarting the welcome splash for new users"
sudo mkdir -p /etc/skel/.config/autostart
printf '[Desktop Entry]\nType=Application\nName=ArxOS Welcome\nExec=arxos-welcome\nOnlyShowIn=XFCE;\nNoDisplay=true\nX-GNOME-Autostart-Phase=Initialization\nX-KDE-autostart-phase=0\n' | sudo tee /etc/skel/.config/autostart/arxos-welcome.desktop >/dev/null
echo ":: done. Log out (or restart lightdm) to see the greeter."
echo "   For the exact look, install the fonts:  Inter (inter-font) + Playfair Display."
