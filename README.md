# Display Mode Menu

Simple Windows display switcher.

Use it when you want one desktop icon with two choices:

- **Home**: turn on all displays using Windows Extend mode.
- **Away**: use only the primary display.

## How to use it

1. Download or clone this folder.
2. Double-click `Install Desktop Shortcut.cmd`.
3. Double-click the new `Display Mode Menu` shortcut on your desktop.
4. Pick `Home` or `Away`.

## Files

- `DisplayModeMenu.ps1`: the real script.
- `Display Mode Menu.cmd`: opens the menu.
- `Home.cmd`: switches straight to Home.
- `Away.cmd`: switches straight to Away.
- `Install Desktop Shortcut.cmd`: creates the desktop shortcut.

## Important

`Away` means "PC screen only" in Windows terms.

Windows decides which monitor is the primary display. If Away keeps the wrong screen on, open Windows Display Settings and set the screen you want as the primary display.

## What it uses

This uses the built-in Windows `SetDisplayConfig` API. It does not install any extra software.
