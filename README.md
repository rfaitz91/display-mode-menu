# Display Mode Menu

Simple Windows display switcher.

Use it when you want one desktop icon with two choices:

- **Home**: turn on all displays using Windows Extend mode.
- **Away**: use only the primary display.

## What it does

This tool is a lightweight Windows shortcut that lets a user switch display modes without opening Windows Display Settings.

When installed, it copies one command file into the user's Documents folder and creates a desktop shortcut. It does not install software in Program Files, add a Windows service, create a scheduled task, install drivers, or modify the registry.

When the user clicks **Home**, the tool asks Windows to enable the normal extended desktop display mode. This is equivalent to pressing `Win + P` and choosing **Extend**.

When the user clicks **Away**, the tool asks Windows to use only the primary display. This is equivalent to pressing `Win + P` and choosing **PC screen only**.

The display change is performed through Microsoft's built-in Windows display configuration API, `SetDisplayConfig`, which is part of `user32.dll`. The script is not directly manipulating display drivers or monitor hardware. It is simply asking Windows to apply one of its standard display layouts.

In short:

- **Install action**: copies one file to `Documents\Display Mode Menu` and creates a desktop shortcut.
- **Home action**: switches Windows display mode to **Extend**.
- **Away action**: switches Windows display mode to **PC screen only**.
- **No background process** remains running after the user closes the menu.
- **No drivers, services, scheduled tasks, registry changes, or third-party dependencies** are added.

## How to use it

1. Download the ZIP.
2. Extract it.
3. Double-click `Install Display Mode Menu.cmd`.
4. Click `Install / Update Desktop Shortcut`.
5. Click `Yes` when it asks to install into your Documents folder.
6. Double-click the new `Display Mode Menu` shortcut on your desktop.
7. Pick `Home` or `Away`.

Home and Away are only shown after the app is installed. The downloaded copy is install-only.

The installer copies the app into:

`Documents\Display Mode Menu`

After that, you can delete the downloaded ZIP and extracted download folder. Keep the `Documents\Display Mode Menu` folder unless you want to uninstall it.

## Files

- `Install Display Mode Menu.cmd`: the whole app and installer.

## Important

`Away` means "PC screen only" in Windows terms.

Windows decides which monitor is the primary display. If Away keeps the wrong screen on, open Windows Display Settings and set the screen you want as the primary display.

## Updating

Download the newest ZIP, extract it, run `Install Display Mode Menu.cmd`, and click `Install / Update Desktop Shortcut` again. It will replace the copy in `Documents\Display Mode Menu` and update the desktop shortcut.

## Uninstalling

Delete the desktop shortcut and delete this folder:

`Documents\Display Mode Menu`

## What it uses

This uses the built-in Windows `SetDisplayConfig` API. It does not install any extra software.
