# Display Mode Menu

Simple Windows display switcher.

Use it when you want one desktop icon with two choices:

- **Home**: turn on all displays using Windows Extend mode.
- **Away**: use only the primary display.

## How to use it

1. Download the ZIP.
2. Extract it.
3. Double-click `DisplayModeMenu.cmd`.
4. Click `Install / Update Desktop Shortcut`.
5. Click `Yes` when it asks to install into your Documents folder.
6. Double-click the new `Display Mode Menu` shortcut on your desktop.
7. Pick `Home` or `Away`.

Home and Away are only shown after the app is installed. The downloaded copy is install-only.

The installer copies the app into:

`Documents\Display Mode Menu`

After that, you can delete the downloaded ZIP and extracted download folder. Keep the `Documents\Display Mode Menu` folder unless you want to uninstall it.

## Files

- `DisplayModeMenu.cmd`: the whole app and installer.

## Important

`Away` means "PC screen only" in Windows terms.

Windows decides which monitor is the primary display. If Away keeps the wrong screen on, open Windows Display Settings and set the screen you want as the primary display.

## Updating

Download the newest ZIP, extract it, run `DisplayModeMenu.cmd`, and click `Install / Update Desktop Shortcut` again. It will replace the copy in `Documents\Display Mode Menu` and update the desktop shortcut.

## Uninstalling

Delete the desktop shortcut and delete this folder:

`Documents\Display Mode Menu`

## What it uses

This uses the built-in Windows `SetDisplayConfig` API. It does not install any extra software.
