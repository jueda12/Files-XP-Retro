# Building Files XP Retro

The application is a WinUI/Windows App SDK project and must be compiled on Windows.

## Easiest method: GitHub Actions

1. Create a GitHub repository and upload this source tree.
2. Open **Actions**.
3. Select **Build Files XP Retro**.
4. Choose **Run workflow**.
5. When the run finishes, download the `Files-XP-Retro-4.2.2-x64` artifact.
6. Extract it and run `Install-XPRetro.ps1`.

The workflow creates a self-signed x64 MSIX package. It does not need private signing secrets.

## Local Windows build

Open a Visual Studio Developer PowerShell in the repository root and run:

```powershell
pwsh ./build/Build-XPRetro.ps1 -Architecture x64 -Configuration Release
```

The installable package will be written to:

```text
artifacts\XP-Retro-Package
```

## Why the output is MSIX rather than one portable EXE

Files uses packaged app identity, Windows shell integrations, an execution alias,
native helper executables, a COM server, and package manifest declarations.
The runnable `Files.exe` is inside the installed package, but distributing only
that executable would omit required components and integrations.
