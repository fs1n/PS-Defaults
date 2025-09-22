# PS-Defaults.Default PowerShell Module
# Core functionality - basic logging, configuration, error handling, and utilities

# Get the path of the module root
$ModuleRoot = $PSScriptRoot

# Import all private functions first (shared across modules)
$PrivateFunctionPath = Join-Path -Path $ModuleRoot -ChildPath 'Private'
if (Test-Path $PrivateFunctionPath) {
    Get-ChildItem -Path $PrivateFunctionPath -Filter '*.ps1' -Recurse | ForEach-Object {
        . $_.FullName
    }
}

# Import core/default public functions
$DefaultFunctionFolders = @('Logging', 'ErrorHandling', 'Configuration', 'Utilities')
foreach ($Folder in $DefaultFunctionFolders) {
    $FolderPath = Join-Path -Path $ModuleRoot -ChildPath "Public\$Folder"
    if (Test-Path $FolderPath) {
        Get-ChildItem -Path $FolderPath -Filter '*.ps1' -Recurse | ForEach-Object {
            . $_.FullName
        }
    }
}

# Initialize module variables
$TempPath = if ($env:TEMP) { $env:TEMP } elseif ($env:TMPDIR) { $env:TMPDIR } else { '/tmp' }
$DefaultLogPath = Join-Path -Path $TempPath -ChildPath 'PS-Defaults'

$Script:PSDefaultsConfig = @{
    LogLevel = 'Information'
    LogPath = $DefaultLogPath
    WebhookUrl = $null
    MaxLogSize = 10MB
    LogRetentionDays = 30
}

# Ensure log directory exists
try {
    if (-not (Test-Path $Script:PSDefaultsConfig.LogPath)) {
        New-Item -Path $Script:PSDefaultsConfig.LogPath -ItemType Directory -Force | Out-Null
    }
} catch {
    # Fallback to current directory if temp path fails
    $Script:PSDefaultsConfig.LogPath = Join-Path -Path (Get-Location) -ChildPath 'PS-Defaults-Logs'
    if (-not (Test-Path $Script:PSDefaultsConfig.LogPath)) {
        New-Item -Path $Script:PSDefaultsConfig.LogPath -ItemType Directory -Force | Out-Null
    }
}

# Export module variables
Export-ModuleMember -Variable PSDefaultsConfig