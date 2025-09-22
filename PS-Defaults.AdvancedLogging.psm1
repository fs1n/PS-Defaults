# PS-Defaults.AdvancedLogging PowerShell Module
# Enhanced logging features with detailed formatting and analysis

# Check if PS-Defaults.Default is loaded or if Write-StandardLog function is available
if (-not (Get-Module PS-Defaults.Default) -and -not (Get-Command Write-StandardLog -ErrorAction SilentlyContinue)) {
    Write-Warning "PS-Defaults.AdvancedLogging requires PS-Defaults.Default to be loaded first."
    Write-Host "Please run: Import-Module PS-Defaults.Default" -ForegroundColor Yellow
    Write-Host "Or use: Import-Module PS-Defaults (which loads Default automatically)" -ForegroundColor Yellow
}

# Get the path of the module root
$ModuleRoot = $PSScriptRoot

# Create advanced logging functions directory if it doesn't exist
$AdvancedLoggingPath = Join-Path -Path $ModuleRoot -ChildPath 'Public\AdvancedLogging'
if (-not (Test-Path $AdvancedLoggingPath)) {
    New-Item -Path $AdvancedLoggingPath -ItemType Directory -Force | Out-Null
}

# Import advanced logging functions
if (Test-Path $AdvancedLoggingPath) {
    Get-ChildItem -Path $AdvancedLoggingPath -Filter '*.ps1' -Recurse | ForEach-Object {
        . $_.FullName
    }
}

# Advanced logging session management
$Script:LogSessions = @{}
$Script:AdvancedLogConfig = @{
    SessionEnabled = $false
    CurrentSession = $null
    LogFormat = 'Standard'
    ForwardingEnabled = $false
    ForwardingEndpoint = $null
    StructuredLogging = $false
}

# Export advanced logging variables
Export-ModuleMember -Variable AdvancedLogConfig