# Installation and Setup Script for PS-Defaults Module

[CmdletBinding()]
param(
    [string]$InstallPath = "",
    [string]$ProfilePath = "",
    [switch]$AddToProfile,
    [switch]$CreateShortcuts,
    [switch]$WhatIf
)

Write-Host "PS-Defaults Module Installation Script" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

# Determine installation path
if (-not $InstallPath) {
    if ($IsWindows -or $PSVersionTable.PSEdition -eq 'Desktop') {
        $InstallPath = Join-Path -Path $env:USERPROFILE -ChildPath "Documents\PowerShell\Modules\PS-Defaults"
    } else {
        $InstallPath = Join-Path -Path $HOME -ChildPath ".local/share/powershell/Modules/PS-Defaults"
    }
}

Write-Host "Installation path: $InstallPath" -ForegroundColor Cyan

# Determine PowerShell profile path
if (-not $ProfilePath) {
    $ProfilePath = $PROFILE.CurrentUserCurrentHost
}

Write-Host "PowerShell profile: $ProfilePath" -ForegroundColor Cyan

if ($WhatIf) {
    Write-Host "`nWhatIf Mode - No changes will be made" -ForegroundColor Yellow
    Write-Host "Would perform the following actions:" -ForegroundColor Yellow
    Write-Host "- Copy module files to: $InstallPath" -ForegroundColor White
    if ($AddToProfile) {
        Write-Host "- Add import statement to PowerShell profile" -ForegroundColor White
    }
    if ($CreateShortcuts) {
        Write-Host "- Create desktop shortcuts for examples" -ForegroundColor White
    }
    exit 0
}

try {
    # Create installation directory
    Write-Host "`nCreating installation directory..." -ForegroundColor Yellow
    if (-not (Test-Path $InstallPath)) {
        New-Item -Path $InstallPath -ItemType Directory -Force | Out-Null
        Write-Host "Created directory: $InstallPath" -ForegroundColor Green
    } else {
        Write-Host "Directory already exists: $InstallPath" -ForegroundColor Yellow
    }

    # Copy module files
    Write-Host "`nCopying module files..." -ForegroundColor Yellow
    $SourcePath = $PSScriptRoot
    
    # Copy main module files
    Copy-Item -Path (Join-Path $SourcePath "PS-Defaults.psd1") -Destination $InstallPath -Force
    Copy-Item -Path (Join-Path $SourcePath "PS-Defaults.psm1") -Destination $InstallPath -Force
    Write-Host "Copied main module files" -ForegroundColor Green
    
    # Copy subdirectories
    $SubDirectories = @("Public", "Private", "Examples")
    foreach ($SubDir in $SubDirectories) {
        $SubDirSource = Join-Path $SourcePath $SubDir
        $SubDirDest = Join-Path $InstallPath $SubDir
        if (Test-Path $SubDirSource) {
            Copy-Item -Path $SubDirSource -Destination $SubDirDest -Recurse -Force
            Write-Host "Copied $SubDir directory" -ForegroundColor Green
        }
    }
    
    # Copy README and LICENSE
    $DocFiles = @("README.md", "LICENSE")
    foreach ($DocFile in $DocFiles) {
        $DocSource = Join-Path $SourcePath $DocFile
        if (Test-Path $DocSource) {
            Copy-Item -Path $DocSource -Destination $InstallPath -Force
            Write-Host "Copied $DocFile" -ForegroundColor Green
        }
    }

    # Test module installation
    Write-Host "`nTesting module installation..." -ForegroundColor Yellow
    try {
        Import-Module $InstallPath -Force
        $ModuleInfo = Get-Module PS-Defaults
        if ($ModuleInfo) {
            Write-Host "Module installation successful!" -ForegroundColor Green
            Write-Host "Module version: $($ModuleInfo.Version)" -ForegroundColor Cyan
            Write-Host "Exported functions: $($ModuleInfo.ExportedFunctions.Count)" -ForegroundColor Cyan
        }
    } catch {
        Write-Host "Warning: Module test failed: $($_.Exception.Message)" -ForegroundColor Red
    }

    # Add to PowerShell profile
    if ($AddToProfile) {
        Write-Host "`nAdding to PowerShell profile..." -ForegroundColor Yellow
        
        $ImportStatement = "Import-Module '$InstallPath' -Force"
        
        if (Test-Path $ProfilePath) {
            $ProfileContent = Get-Content $ProfilePath -Raw
            if ($ProfileContent -notmatch [regex]::Escape($ImportStatement)) {
                Add-Content -Path $ProfilePath -Value "`n# PS-Defaults Module"
                Add-Content -Path $ProfilePath -Value $ImportStatement
                Write-Host "Added import statement to profile" -ForegroundColor Green
            } else {
                Write-Host "Import statement already exists in profile" -ForegroundColor Yellow
            }
        } else {
            # Create profile directory if it doesn't exist
            $ProfileDir = Split-Path $ProfilePath -Parent
            if (-not (Test-Path $ProfileDir)) {
                New-Item -Path $ProfileDir -ItemType Directory -Force | Out-Null
            }
            
            # Create new profile
            @"
# PowerShell Profile
# PS-Defaults Module
$ImportStatement
"@ | Set-Content -Path $ProfilePath -Encoding UTF8
            Write-Host "Created new PowerShell profile with PS-Defaults import" -ForegroundColor Green
        }
    }

    # Create desktop shortcuts (Windows only)
    if ($CreateShortcuts -and ($IsWindows -or $PSVersionTable.PSEdition -eq 'Desktop')) {
        Write-Host "`nCreating desktop shortcuts..." -ForegroundColor Yellow
        
        $DesktopPath = [Environment]::GetFolderPath("Desktop")
        $ExamplesPath = Join-Path $InstallPath "Examples"
        
        if (Test-Path $ExamplesPath) {
            $WShell = New-Object -ComObject WScript.Shell
            
            # Create shortcut for example usage
            $ExampleUsagePath = Join-Path $ExamplesPath "ExampleUsage.ps1"
            if (Test-Path $ExampleUsagePath) {
                $Shortcut = $WShell.CreateShortcut((Join-Path $DesktopPath "PS-Defaults Example.lnk"))
                $Shortcut.TargetPath = "powershell.exe"
                $Shortcut.Arguments = "-File `"$ExampleUsagePath`""
                $Shortcut.WorkingDirectory = $InstallPath
                $Shortcut.Description = "PS-Defaults Module Example"
                $Shortcut.Save()
                Write-Host "Created desktop shortcut for examples" -ForegroundColor Green
            }
        }
    }

    Write-Host "`n==============================" -ForegroundColor Green
    Write-Host "Installation completed successfully!" -ForegroundColor Green
    Write-Host "==============================" -ForegroundColor Green
    
    Write-Host "`nNext steps:" -ForegroundColor Yellow
    Write-Host "1. Restart PowerShell to load the module automatically (if added to profile)" -ForegroundColor White
    Write-Host "2. Or manually import with: Import-Module '$InstallPath'" -ForegroundColor White
    Write-Host "3. Run examples from: $(Join-Path $InstallPath 'Examples')" -ForegroundColor White
    Write-Host "4. Check the README.md for detailed usage instructions" -ForegroundColor White

} catch {
    Write-Host "`nInstallation failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please check permissions and try again." -ForegroundColor Red
    exit 1
}