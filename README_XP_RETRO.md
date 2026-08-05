# Files XP Retro v0.1

Files XP Retro is an **unofficial derivative** of Files 4.2.2. It keeps Files' modern file-management features and adds a Windows XP Luna-inspired visual treatment.

## Included in this prototype

- Luna blue title and tab strip
- Tahoma as the default interface font
- XP beige toolbars and status bar
- White address and file areas
- Pale-blue navigation and information panes
- Square, lightly rounded controls and classic grey-blue borders
- Solid backgrounds by default (Mica and Acrylic are disabled)
- App display name changed to **Files XP Retro**

This prototype intentionally retains the upstream development package identity (`FilesDev`) and `files-dev:` protocol. That keeps the existing launcher and shell-integration components working and lets the build install alongside normal Store and sideload releases of Files. It will conflict with another locally built **Files - Dev** package.

## Build on Windows

1. Install Visual Studio 2022 with WinUI application development, the required Windows SDK, .NET SDK, MSVC tools, ATL, and Windows App SDK components listed by the Files project.
2. Open `Files.slnx`.
3. Set `Files.App` as the startup item.
4. Select `Debug`, `x64` (or your device architecture), and `Local Machine`.
5. Build and run.

Command-line build from a Visual Studio Developer PowerShell:

```powershell
msbuild -restore Files.slnx -p:Configuration=Debug -p:Platform=x64 -v:quiet -clp:ErrorsOnly
```

## Resetting the retro defaults

The XP defaults are used for a fresh `FilesDev` profile. If an older development build has already created settings, uninstall that development package and remove its local package data, or import a settings file containing the XP colors.

## Attribution and licenses

This derivative preserves the original copyright notices and the repository's MIT and MPL-2.0 license files. Files XP Retro is not produced or endorsed by Files Community or Microsoft. Windows XP is a Microsoft product name; this project only uses an original color treatment inspired by its interface.

## Build-ready v0.2 additions

This source package includes:

- `.github/workflows/build-xp-retro.yml` — one-click GitHub Actions build
- `build/Build-XPRetro.ps1` — local Windows build and packaging script
- `build/Install-XPRetro.ps1` — current-user certificate and MSIX installer
- `build/README.md` — concise build instructions

The produced artifact is a self-signed x64 MSIX package. `Files.exe` and the
native helper executables are contained in that package.
