# arxos-greeter

The ARXOS login screen. It is one greeter that does three jobs:

- It is the login screen. LightDM shows it when the computer starts.
- It is the lock screen. light-locker locks the session back to this greeter.
- It is the default login for every user: the live user, users the installer
  creates, and users you create later.

It uses the stable `lightdm-gtk-greeter`, themed for ARXOS. It replaces the old
webkit greeter, which failed logins.

## Install

```bash
sudo bash install.sh
sudo systemctl restart lightdm   # applies now. this ends the current session.
```

The installer is idempotent. You can run it again with no harm.

## What it sets

- Packages: `lightdm`, `lightdm-gtk-greeter`, `light-locker`.
- Greeter config: `/etc/lightdm/lightdm-gtk-greeter.conf` (dark theme, ARXOS
  background, clock, session picker, power controls).
- LightDM default greeter: `/etc/lightdm/lightdm.conf.d/10-arxos.conf`.
- Lock screen for all users: `light-locker` autostart in `/etc/xdg/autostart`
  and in `/etc/skel`, so new users get it too.
- LightDM enabled as the display manager.

## Files

| Path | Purpose |
|---|---|
| `install.sh` | Installer |
| `data/lightdm-gtk-greeter.conf` | The greeter appearance |
| `data/autostart/light-locker.desktop` | Locks the session to the greeter |
