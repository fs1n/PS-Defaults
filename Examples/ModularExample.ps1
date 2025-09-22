# Example script demonstrating the modular PS-Defaults framework
# This script shows how to use different modules for targeted functionality

Write-Host "=== PS-Defaults Modular Framework Example ===" -ForegroundColor Green

# Example 1: Basic usage with core functions only
Write-Host "`n1. Basic Usage (Core Functions Only)" -ForegroundColor Yellow
Import-Module ".\PS-Defaults.Default.psd1" -Force

# Initialize logging
Initialize-StandardLogging -LogPath "./example-logs" -RetentionDays 7
Write-InfoLog -Message "Core module loaded - basic logging active" -Source "ExampleScript"

# Basic configuration
Set-StandardConfig -Key "ExampleSetting" -Value "BasicValue"
$setting = Get-StandardConfig -Key "ExampleSetting"
Write-InfoLog -Message "Configuration retrieved: $setting" -Source "ExampleScript"

# Example 2: Enhanced logging with AdvancedLogging module
Write-Host "`n2. Enhanced Logging (AdvancedLogging Module)" -ForegroundColor Yellow
Import-Module ".\PS-Defaults.AdvancedLogging.psd1" -Force

# Start logging session with performance tracking
Start-LogSession -SessionName "DemoSession" -TrackPerformance
Write-InfoLog -Message "Advanced logging session started" -Source "ExampleScript"

# Use detailed logging with performance metrics
Write-DetailedLog -Message "Processing data batch" -Level Information -Source "DataProcessor" -Category "Performance" -IncludePerformanceData

# Write structured log entry
Write-StructuredLog -Message "User action performed" -Level Information -Source "UserTracking" -CustomFields @{
    Action = "FileDownload"
    FileName = "report.pdf"
    FileSize = "2.5MB"
    Duration = "1.2s"
}

# Stop session and get metrics
$metrics = Stop-LogSession -SessionName "DemoSession"
Write-Host "Session Duration: $($metrics.Duration)" -ForegroundColor Cyan
Write-Host "Log Entries: $($metrics.LogEntryCount)" -ForegroundColor Cyan

# Example 3: Network testing with Networking module
Write-Host "`n3. Network Testing (Networking Module)" -ForegroundColor Yellow
Import-Module ".\PS-Defaults.Networking.psd1" -Force

# Test network connectivity
$networkTest = Test-NetworkConnectivity -ComputerName "8.8.8.8" -Port 53 -TestPing -TestDNS
Write-Host "Network Test Success: $($networkTest.Success)" -ForegroundColor $(if($networkTest.Success) {'Green'} else {'Red'})

# Test web endpoint
$webTest = Test-WebEndpoint -Uri "https://httpbin.org/get" -ExpectedStatusCode 200
Write-Host "Web Endpoint Test Success: $($webTest.Success)" -ForegroundColor $(if($webTest.Success) {'Green'} else {'Red'})

# Example 4: System monitoring with System module
Write-Host "`n4. System Monitoring (System Module)" -ForegroundColor Yellow
Import-Module ".\PS-Defaults.System.psd1" -Force

# Get system information
$sysInfo = Get-SystemInfo
Write-Host "OS: $($sysInfo.OperatingSystem)" -ForegroundColor Cyan
Write-Host "PowerShell Version: $($sysInfo.PowerShellVersion)" -ForegroundColor Cyan

# Check disk space
$diskInfo = Get-DiskSpaceInfo -WarningThresholdPercent 20 -CriticalThresholdPercent 10
foreach ($disk in $diskInfo.Disks) {
    $color = if ($disk.FreeSpacePercent -lt 10) { 'Red' } elseif ($disk.FreeSpacePercent -lt 20) { 'Yellow' } else { 'Green' }
    Write-Host "Disk $($disk.DriveLetter): $($disk.FreeSpacePercent)% free" -ForegroundColor $color
}

# Example 5: Log analysis and reporting
Write-Host "`n5. Log Analysis and Reporting" -ForegroundColor Yellow

# Analyze the logs we created
$logAnalysis = Get-LogAnalysis -LogPath "./example-logs"
Write-Host "Total Log Entries: $($logAnalysis.TotalEntries)" -ForegroundColor Cyan
Write-Host "Error Count: $($logAnalysis.ErrorCount)" -ForegroundColor Cyan
Write-Host "Warning Count: $($logAnalysis.WarningCount)" -ForegroundColor Cyan

# Generate HTML report
$reportPath = "./example-logs/analysis-report.html"
Export-LogReport -LogPath "./example-logs" -OutputPath $reportPath -Format HTML
Write-Host "HTML report generated: $reportPath" -ForegroundColor Green

# Example 6: Demonstrate backward compatibility
Write-Host "`n6. Backward Compatibility Test" -ForegroundColor Yellow

# Remove all modules first
Get-Module PS-Defaults* | Remove-Module -Force

# Import main module (should load Default automatically)
Import-Module ".\PS-Defaults.psd1" -Force

# Test that all core functions still work
Write-InfoLog -Message "Backward compatibility test successful" -Source "ExampleScript"
$configTest = Get-StandardConfig -Key "ExampleSetting" -Default "NotFound"
Write-Host "Configuration still available: $configTest" -ForegroundColor Green

Write-Host "`n=== Modular Framework Example Complete ===" -ForegroundColor Green
Write-Host "Check './example-logs' for generated logs and reports" -ForegroundColor Yellow
Write-Host "`nModular Benefits Demonstrated:" -ForegroundColor Cyan
Write-Host "- Import only what you need (reduces memory footprint)" -ForegroundColor White
Write-Host "- Advanced features available when needed" -ForegroundColor White
Write-Host "- Full backward compatibility maintained" -ForegroundColor White
Write-Host "- Clear separation of concerns" -ForegroundColor White