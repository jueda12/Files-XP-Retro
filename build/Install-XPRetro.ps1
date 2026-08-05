#requires -Version 5.1
[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if ([System.Environment]::OSVersion.Platform -ne [System.PlatformID]::Win32NT) {
    throw "Files XP Retro can only be installed on Windows."
}

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $process = Start-Process powershell.exe -Verb RunAs -Wait -PassThru -ArgumentList @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", "`"$PSCommandPath`""
    )
    exit $process.ExitCode
}

$PackageRoot = $PSScriptRoot
$CertificatePath = Join-Path $PackageRoot "Files-XP-Retro-SelfSigned.cer"

if (-not (Test-Path $CertificatePath)) {
    throw "Certificate not found: $CertificatePath"
}

$package = Get-ChildItem $PackageRoot -Recurse -Include *.msixbundle, *.msix |
    Where-Object { $_.FullName -notmatch "\\Dependencies\\" } |
    Sort-Object { if ($_.Extension -eq ".msixbundle") { 0 } else { 1 } } |
    Select-Object -First 1

if (-not $package) {
    throw "No Files XP Retro MSIX package was found."
}

$architecture = [Environment]::GetEnvironmentVariable("PROCESSOR_ARCHITECTURE")
$dependencies = @(
    Get-ChildItem $PackageRoot -Recurse -Include *.appx, *.msix |
        Where-Object {
            $_.FullName -match "\Dependencies\\" -and
            $_.FullName -ne $package.FullName -and
            $_.Directory.Name -ieq $architecture
        } |
        ForEach-Object { $_.FullName }
)

Write-Host "Installing the Files XP Retro test certificate for this computer..."
Import-Certificate `
    -FilePath $CertificatePath `
    -CertStoreLocation "Cert:\LocalMachine\TrustedPeople" |
    Out-Null

Write-Host "Installing $($package.Name)..."
if ($dependencies.Count -gt 0) {
    Add-AppxPackage -Path $package.FullName -DependencyPath $dependencies -ForceApplicationShutdown
} else {
    Add-AppxPackage -Path $package.FullName -ForceApplicationShutdown
}

Write-Host ""
Write-Host "Files XP Retro was installed successfully."
Write-Host "Open it from the Start menu."
