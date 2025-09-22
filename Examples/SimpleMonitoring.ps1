# Simple Monitoring Script Example
# This script demonstrates how to use PS-Defaults for basic system monitoring

param(
    [string]$WebhookUrl = "",
    [string]$LogPath = "./monitoring-logs",
    [int]$DiskWarningThreshold = 20,
    [int]$DiskCriticalThreshold = 10
)

# Import the PS-Defaults module
Import-Module (Join-Path -Path $PSScriptRoot -ChildPath "..\PS-Defaults.psd1") -Force

# Configure the module
if ($WebhookUrl) {
    Set-StandardConfig -Key "WebhookUrl" -Value $WebhookUrl
}

Initialize-StandardLogging -LogPath $LogPath -RetentionDays 30

Write-InfoLog -Message "Starting system monitoring" -Source "MonitoringScript"

try {
    # Check disk space
    Write-InfoLog -Message "Checking disk space" -Source "MonitoringScript"
    $DiskInfo = Get-DiskSpaceInfo -WarningThresholdPercent $DiskWarningThreshold -CriticalThresholdPercent $DiskCriticalThreshold
    
    foreach ($Alert in $DiskInfo.Alerts) {
        if ($Alert.Level -eq 'Critical') {
            Write-ErrorLog -Message $Alert.Message -Source "MonitoringScript"
            if ($WebhookUrl) {
                Send-ErrorWebhook -Message $Alert.Message -Source "DiskMonitor" -Environment "Production"
            }
        } elseif ($Alert.Level -eq 'Warning') {
            Write-WarningLog -Message $Alert.Message -Source "MonitoringScript"
            if ($WebhookUrl) {
                Send-NotificationWebhook -Message $Alert.Message -Level "Warning" -Source "DiskMonitor"
            }
        }
    }
    
    # Test internet connectivity
    Write-InfoLog -Message "Testing internet connectivity" -Source "MonitoringScript"
    $ConnTest = Test-NetworkConnectivity -ComputerName "8.8.8.8" -TestPing
    
    if (-not $ConnTest.Success) {
        $ErrorMsg = "Internet connectivity test failed"
        Write-ErrorLog -Message $ErrorMsg -Source "MonitoringScript"
        if ($WebhookUrl) {
            Send-ErrorWebhook -Message $ErrorMsg -Source "ConnectivityMonitor" -Environment "Production"
        }
    } else {
        Write-InfoLog -Message "Internet connectivity test passed" -Source "MonitoringScript"
    }
    
    # Get basic system info
    $SystemInfo = Get-SystemInfo
    Write-InfoLog -Message "System: $($SystemInfo.ComputerName) - $($SystemInfo.OperatingSystem.Name)" -Source "MonitoringScript"
    
    Write-InfoLog -Message "Monitoring cycle completed successfully" -Source "MonitoringScript"
    
} catch {
    Write-ErrorLog -Message "Monitoring script failed: $($_.Exception.Message)" -Source "MonitoringScript"
    if ($WebhookUrl) {
        Send-ErrorWebhook -ErrorRecord $_ -Source "MonitoringScript" -Environment "Production"
    }
    exit 1
}

Write-InfoLog -Message "Monitoring script finished" -Source "MonitoringScript"