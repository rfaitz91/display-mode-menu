# Display Mode Menu

Simple Windows display switcher.

Use it when you want one desktop icon with two choices:

- **Home**: turn on all displays using Windows Extend mode.
- **Away**: use only the primary display.

## How to use it

1. Download or clone this folder.
2. Double-click `Install Desktop Shortcut.vbs`.
3. Double-click the new `Display Mode Menu` shortcut on your desktop.
4. Pick `Home` or `Away`.

The installer copies the app into:

`Documents\Display Mode Menu`

After that, you can delete the downloaded ZIP and extracted download folder. Keep the `Documents\Display Mode Menu` folder unless you want to uninstall it.

## Files

- `DisplayModeMenu.ps1`: the real script.
- `Install Desktop Shortcut.vbs`: creates the desktop shortcut without leaving a command window open.
- `Display Mode Menu.vbs`: opens the menu without a command window.
- `Home.vbs`: switches straight to Home without a command window.
- `Away.vbs`: switches straight to Away without a command window.
- `.cmd` files: backup launchers for systems where `.vbs` files are blocked.

## Important

`Away` means "PC screen only" in Windows terms.

Windows decides which monitor is the primary display. If Away keeps the wrong screen on, open Windows Display Settings and set the screen you want as the primary display.

## Updating

Download the newest ZIP, extract it, and run `Install Desktop Shortcut.vbs` again. It will replace the copy in `Documents\Display Mode Menu` and update the desktop shortcut.

## Uninstalling

Delete the desktop shortcut and delete this folder:

`Documents\Display Mode Menu`

## What it uses

This uses the built-in Windows `SetDisplayConfig` API. It does not install any extra software.
