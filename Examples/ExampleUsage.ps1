# Example script demonstrating PS-Defaults module usage
# This script shows how to use the standardized functions for logging, error handling, and system monitoring

# Import the PS-Defaults module
Import-Module ".\PS-Defaults.psd1" -Force

# Configure logging and webhooks
Write-Host "=== PS-Defaults Module Example ===" -ForegroundColor Green

# Initialize logging
Initialize-StandardLogging -LogPath "./example-logs" -RetentionDays 7
Write-InfoLog -Message "Example script started" -Source "ExampleScript"

# Set some configuration values
Set-StandardConfig -Key "ExampleKey" -Value "ExampleValue"
Set-StandardConfig -Key "App.Version" -Value "1.0.0"

# Demonstrate configuration retrieval
$ExampleValue = Get-StandardConfig -Key "ExampleKey" -Default "DefaultValue"
$AppVersion = Get-StandardConfig -Key "App.Version" -Default "Unknown"

Write-InfoLog -Message "Configuration loaded: ExampleKey=$ExampleValue, App.Version=$AppVersion" -Source "ExampleScript"

# Demonstrate safe command execution
Write-InfoLog -Message "Testing safe command execution" -Source "ExampleScript"
$Result = Invoke-SafeCommand -ScriptBlock {
    # Simulate a command that might fail occasionally
    $Random = Get-Random -Minimum 1 -Maximum 10
    if ($Random -lt 3) {
        throw "Simulated failure (random: $Random)"
    }
    return "Success! Random number was: $Random"
} -RetryCount 3 -RetryDelay 1 -Source "SafeCommandTest" -OnError Continue

if ($Result) {
    Write-InfoLog -Message "Safe command result: $Result" -Source "ExampleScript"
} else {
    Write-WarningLog -Message "Safe command failed after retries" -Source "ExampleScript"
}

# Demonstrate system information gathering
Write-InfoLog -Message "Gathering system information" -Source "ExampleScript"
$SystemInfo = Get-SystemInfo -IncludePerformance -IncludeDiskSpace

Write-Host "`nSystem Information:" -ForegroundColor Yellow
Write-Host "Computer Name: $($SystemInfo.ComputerName)" -ForegroundColor Cyan
Write-Host "OS: $($SystemInfo.OperatingSystem.Name)" -ForegroundColor Cyan
Write-Host "PowerShell Version: $($SystemInfo.PowerShellVersion)" -ForegroundColor Cyan

if ($SystemInfo.Performance) {
    Write-Host "Memory Usage: $($SystemInfo.Performance.MemoryUsagePercent)%" -ForegroundColor Cyan
}

# Demonstrate disk space monitoring
Write-InfoLog -Message "Checking disk space" -Source "ExampleScript"
$DiskInfo = Get-DiskSpaceInfo -WarningThresholdPercent 80 -CriticalThresholdPercent 90

Write-Host "`nDisk Space Information:" -ForegroundColor Yellow
foreach ($Drive in $DiskInfo.Drives) {
    $Color = 'Green'
    if ($Drive.FreeSpacePercent -lt 20) { $Color = 'Red' }
    elseif ($Drive.FreeSpacePercent -lt 50) { $Color = 'Yellow' }
    
    Write-Host "Drive $($Drive.Drive): $($Drive.FreeSizeGB) GB free ($($Drive.FreeSpacePercent)%)" -ForegroundColor $Color
}

if ($DiskInfo.Alerts.Count -gt 0) {
    Write-Host "`nDisk Space Alerts:" -ForegroundColor Red
    foreach ($Alert in $DiskInfo.Alerts) {
        Write-Host "  $($Alert.Level): $($Alert.Message)" -ForegroundColor Red
    }
}

# Demonstrate network connectivity testing
Write-InfoLog -Message "Testing network connectivity" -Source "ExampleScript"
$ConnTest = Test-NetworkConnectivity -ComputerName "8.8.8.8" -TestPing -TestDNS

Write-Host "`nNetwork Connectivity Test (8.8.8.8):" -ForegroundColor Yellow
Write-Host "DNS Resolution: $($ConnTest.DNS.Success)" -ForegroundColor $(if($ConnTest.DNS.Success) {'Green'} else {'Red'})
Write-Host "Ping Test: $($ConnTest.Ping.Success)" -ForegroundColor $(if($ConnTest.Ping.Success) {'Green'} else {'Red'})
Write-Host "Overall Success: $($ConnTest.Success)" -ForegroundColor $(if($ConnTest.Success) {'Green'} else {'Red'})

# Demonstrate utility functions
Write-InfoLog -Message "Demonstrating utility functions" -Source "ExampleScript"

$TempDir = New-TemporaryDirectory -Prefix "PSDefaultsExample"
Write-Host "`nUtility Functions:" -ForegroundColor Yellow
Write-Host "Created temporary directory: $TempDir" -ForegroundColor Cyan

$RandomString = Get-RandomString -Length 12 -IncludeSpecialChars
Write-Host "Random string generated: $RandomString" -ForegroundColor Cyan

$FileSize = Format-FileSize -Bytes 1073741824
Write-Host "Formatted file size (1GB): $FileSize" -ForegroundColor Cyan

$IsAdmin = Test-Administrator
Write-Host "Running as administrator: $IsAdmin" -ForegroundColor Cyan

# Clean up temporary directory
Remove-TemporaryDirectory -Path $TempDir -Force
Write-Host "Cleaned up temporary directory" -ForegroundColor Cyan

# Demonstrate notification (without actually sending to avoid webhook requirements)
Write-InfoLog -Message "Example would send notification webhook here (if configured)" -Source "ExampleScript"

# Example of how you would send notifications:
# Set-StandardConfig -Key "WebhookUrl" -Value "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
# Send-NotificationWebhook -Message "Example script completed successfully" -Level "Success" -Source "ExampleScript"

Write-InfoLog -Message "Example script completed successfully" -Source "ExampleScript"
Write-Host "`n=== Example Complete ===" -ForegroundColor Green
Write-Host "Check the './example-logs' directory for log files." -ForegroundColor Yellow