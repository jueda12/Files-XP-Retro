#requires -Version 7.0
<#
.SYNOPSIS
Builds a self-signed x64 or ARM64 MSIX package for Files XP Retro.

.DESCRIPTION
Run this from a Visual Studio Developer PowerShell, or let the included
GitHub Actions workflow run it on a Windows hosted runner.
#>

[CmdletBinding()]
param(
    [ValidateSet("x64", "arm64")]
    [string]$Architecture = "x64",

    [ValidateSet("Debug", "Release")]
    [string]$Configuration = "Release"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if (-not $IsWindows) {
    throw "This build requires Windows, Visual Studio/MSBuild, the Windows SDK, and Windows App SDK tooling."
}

$RepoRoot = Split-Path -Parent $PSScriptRoot
$SolutionPath = Join-Path $RepoRoot "Files.slnx"
$AppProjectPath = Join-Path $RepoRoot "src\Files.App\Files.App.csproj"
$LauncherProjectPath = Join-Path $RepoRoot "src\Files.App.Launcher\Files.App.Launcher.vcxproj"
$OutputDir = Join-Path $RepoRoot "artifacts\XP-Retro-Package"
$TempDir = Join-Path $RepoRoot "artifacts\XP-Retro-Temp"
$PfxPath = Join-Path $TempDir "Files-XP-Retro-SelfSigned.pfx"
$CerPath = Join-Path $OutputDir "Files-XP-Retro-SelfSigned.cer"

function Resolve-CommandPath([string]$Name) {
    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    return $null
}

function Resolve-MSBuild {
    $msbuild = Resolve-CommandPath "msbuild.exe"
    if ($msbuild) { return $msbuild }

    $vswhere = Join-Path ${env:ProgramFiles(x86)} "Microsoft Visual Studio\Installer\vswhere.exe"
    if (Test-Path $vswhere) {
        $installationPath = & $vswhere -latest -products * -requires Microsoft.Component.MSBuild -property installationPath
        if ($installationPath) {
            $candidate = Join-Path $installationPath "MSBuild\Current\Bin\MSBuild.exe"
            if (Test-Path $candidate) { return $candidate }
        }
    }

    throw "MSBuild was not found. Install Visual Studio with the Windows/WinUI and C++ desktop build tools."
}

function Resolve-NuGet {
    $nuget = Resolve-CommandPath "nuget.exe"
    if ($nuget) { return $nuget }

    $toolsDir = Join-Path $RepoRoot "artifacts\tools"
    New-Item -ItemType Directory -Path $toolsDir -Force | Out-Null
    $nuget = Join-Path $toolsDir "nuget.exe"

    Write-Host "NuGet.exe not found; downloading the official command-line client..."
    Invoke-WebRequest `
        -Uri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" `
        -OutFile $nuget

    return $nuget
}

function Invoke-Checked([string]$FilePath, [string[]]$Arguments) {
    Write-Host "> $FilePath $($Arguments -join ' ')"
    & $FilePath @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed with exit code ${LASTEXITCODE}: $FilePath"
    }
}

if (Test-Path $OutputDir) { Remove-Item $OutputDir -Recurse -Force }
if (Test-Path $TempDir) { Remove-Item $TempDir -Recurse -Force }
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

$MSBuild = Resolve-MSBuild
$NuGet = Resolve-NuGet

Write-Host "Restoring launcher dependencies..."
Invoke-Checked $NuGet @(
    "restore",
    $LauncherProjectPath,
    "-SolutionDirectory", $RepoRoot,
    "-Verbosity", "normal"
)

Write-Host "Building launcher..."
Invoke-Checked $MSBuild @(
    $LauncherProjectPath,
    "-t:Build",
    "-p:Platform=$Architecture",
    "-p:Configuration=$Configuration",
    "-v:minimal"
)

Write-Host "Restoring Files solution..."
Invoke-Checked $MSBuild @(
    $SolutionPath,
    "-t:Restore",
    "-p:Platform=$Architecture",
    "-p:Configuration=$Configuration",
    "-p:PublishReadyToRun=true",
    "-v:minimal"
)

Write-Host "Creating a temporary self-signed code-signing certificate..."
$cert = New-SelfSignedCertificate `
    -Type Custom `
    -Subject "CN=Files" `
    -KeyUsage DigitalSignature `
    -FriendlyName "Files XP Retro temporary package certificate" `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -TextExtension @(
        "2.5.29.37={text}1.3.6.1.5.5.7.3.3",
        "2.5.29.19={text}"
    )

try {
    $pfxBytes = $cert.Export(
        [System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12
    )
    [System.IO.File]::WriteAllBytes($PfxPath, $pfxBytes)
    Export-Certificate -Cert $cert -FilePath $CerPath -Force | Out-Null

    Write-Host "Building and packaging Files XP Retro..."
    Invoke-Checked $MSBuild @(
        $AppProjectPath,
        "-t:Build",
        "-p:Configuration=$Configuration",
        "-p:Platform=$Architecture",
        "-p:AppxBundle=Never",
        "-p:GenerateAppxPackageOnBuild=true",
        "-p:UapAppxPackageBuildMode=SideloadOnly",
        "-p:AppxPackageDir=$OutputDir\",
        "-p:AppxPackageSigningEnabled=true",
        "-p:PackageCertificateKeyFile=$PfxPath",
        "-p:PackageCertificatePassword=",
        "-p:PackageCertificateThumbprint=",
        "-v:minimal"
    )
}
finally {
    if ($cert) {
        Remove-Item "Cert:\CurrentUser\My\$($cert.Thumbprint)" -ErrorAction SilentlyContinue
    }
    if (Test-Path $PfxPath) {
        Remove-Item $PfxPath -Force
    }
}

$installerSource = Join-Path $PSScriptRoot "Install-XPRetro.ps1"
Copy-Item $installerSource (Join-Path $OutputDir "Install-XPRetro.ps1") -Force

$readme = @"
FILES XP RETRO — INSTALLATION

1. Extract this artifact.
2. Right-click Install-XPRetro.ps1 and choose "Run with PowerShell".
3. Confirm the certificate and package installation prompts.

The certificate is self-signed and only identifies this local experimental build.
Windows SmartScreen may warn because it is not signed by a commercial code-signing authority.

To uninstall:
Settings > Apps > Installed apps > Files XP Retro > Uninstall
"@
Set-Content -Path (Join-Path $OutputDir "INSTALL.txt") -Value $readme -Encoding UTF8

$packages = Get-ChildItem $OutputDir -Recurse -Include *.msix, *.msixbundle |
    Where-Object { $_.FullName -notmatch "\\Dependencies\\" }

if (-not $packages) {
    throw "The build completed without producing an MSIX package."
}

Write-Host ""
Write-Host "Build completed."
Write-Host "Installer artifact: $OutputDir"
$packages | ForEach-Object { Write-Host "Package: $($_.FullName)" }
