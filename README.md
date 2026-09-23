# arxos-greeter

The ARXOS login screen. It is one greeter that does three jobs:

- It is the login screen. LightDM shows it when the computer starts.
- It is the lock screen. light-locker locks the session back to this greeter.
- It is the default login for every user: the live user, users the installer
  creates, and users you create later.

The greeter is a full ARXOS HTML theme (the ARXOS mark, orange accents, a clock,
a session picker, and power controls) rendered by **web-greeter**, the maintained
HTML greeter. It replaces the old `lightdm-webkit2-greeter`, which does not build
on current Arch and failed logins.

## Install

```bash
sudo bash install.sh
sudo systemctl restart lightdm   # applies now. this ends the current session.
```

The installer is idempotent. You can run it again with no harm.

## Requirements

- `lightdm`, `light-locker`, `xcb-util-cursor`, `xorg-xsetroot`, `qt6-wayland`
  (installed by `install.sh`).
- `web-greeter` (AUR). The installer installs it through `arx` when available,
  or you install it first. web-greeter is a Qt6 app, so `xcb-util-cursor` is
  required or the greeter will not start.

## What it sets

- The ARXOS HTML theme in `/usr/share/web-greeter/themes/arxos/`.
- web-greeter theme choice in `/etc/lightdm/web-greeter.toml` (`theme = "arxos"`).
- LightDM default greeter in `/etc/lightdm/lightdm.conf.d/10-arxos.conf`
  (`greeter-session=web-greeter`).
- Lock screen for all users: `light-locker` autostart in `/etc/xdg/autostart`
  and in `/etc/skel`, so new users get it too.
- LightDM enabled as the display manager.

## Files

| Path | Purpose |
|---|---|
| `install.sh` | Installer |
| `data/webkit-theme/arxos/index.html` | The ARXOS HTML greeter |
| `data/webkit-theme/arxos/index.yml` | web-greeter theme metadata |
| `data/autostart/light-locker.desktop` | Locks the session to the greeter |

---

<div align="center">
<sub><b>arxos-greeter</b> is part of the <b>ArxOS</b> project, built by <b>Stingray Labs</b>.</sub>
</div>
