# PS-Defaults

A comprehensive PowerShell module that standardizes repeating script functions for IT environments. This module provides a consistent set of tools for logging, error handling, webhooks, configuration management, and common utilities that should be standardized across all PowerShell scripts in the same IT environment.

## Features

### 🔍 **Standardized Logging**
- Consistent log formatting with timestamps, levels, and sources
- Automatic log rotation and retention management
- Multiple log levels (Debug, Information, Warning, Error)
- File and console output

### 🚨 **Error Handling & Webhooks**
- Standardized error reporting to webhooks (Slack, Teams, Generic)
- Safe command execution with retry logic
- Custom exception creation with additional context
- Automatic error logging and notification

### ⚙️ **Configuration Management**
- Centralized configuration system
- Support for multiple configuration sources (Module, Environment, Files)
- JSON configuration file support
- Nested configuration keys with dot notation

### 🌐 **Network & System Utilities**
- Network connectivity testing (ping, port, DNS)
- Web endpoint health checks
- Comprehensive system information gathering
- Disk space monitoring with alerts

### 🛠️ **General Utilities**
- Secure string handling
- Temporary directory management
- File size formatting
- Random string generation
- Administrator privilege checking
- Retry logic for unreliable operations

## Installation

1. **Manual Installation:**
   ```powershell
   # Clone or download the repository
   git clone https://github.com/fs1n/PS-Defaults.git
   
   # Import the module
   Import-Module ".\PS-Defaults\PS-Defaults.psd1"
   ```

2. **Add to PowerShell Profile:**
   ```powershell
   # Add to your PowerShell profile for automatic loading
   Import-Module "C:\Path\To\PS-Defaults\PS-Defaults.psd1"
   ```

## Quick Start

### Basic Logging
```powershell
# Initialize logging (optional - module auto-initializes)
Initialize-StandardLogging -LogPath "C:\Logs\MyApp" -RetentionDays 7

# Write log entries
Write-InfoLog -Message "Application started" -Source "MyApp"
Write-WarningLog -Message "Configuration file not found, using defaults" -Source "MyApp"
Write-ErrorLog -Message "Database connection failed" -Source "MyApp"

# Or use the main logging function
Write-StandardLog -Message "Custom operation completed" -Level Information -Source "MyApp"
```

### Error Handling with Webhooks
```powershell
# Configure webhook for error notifications
Set-StandardConfig -Key "WebhookUrl" -Value "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"

# Safe command execution with automatic error handling
$Result = Invoke-SafeCommand -ScriptBlock {
    # Some risky operation
    Invoke-RestMethod -Uri "https://api.example.com/data"
} -ErrorAction SendWebhook -RetryCount 3 -Source "APICall"

# Manual error reporting
try {
    # Some operation that might fail
} catch {
    Send-ErrorWebhook -ErrorRecord $_ -Source "MyScript" -Environment "Production"
}
```

### Configuration Management
```powershell
# Set configuration values
Set-StandardConfig -Key "DatabaseServer" -Value "prod-sql-01"
Set-StandardConfig -Key "ApiTimeout" -Value 30

# Get configuration values with defaults
$DbServer = Get-StandardConfig -Key "DatabaseServer" -Default "localhost"
$Timeout = Get-StandardConfig -Key "ApiTimeout" -Default 15

# Use configuration files
Set-StandardConfig -Key "Database.ConnectionString" -Value "Server=prod" -Target File -CreateFile
Import-StandardConfig -ConfigFile "production.json" -Merge
```

### System Monitoring
```powershell
# Test network connectivity
$ConnTest = Test-NetworkConnectivity -ComputerName "google.com" -Port 443 -TestPing -TestDNS
if (-not $ConnTest.Success) {
    Write-ErrorLog -Message "Network connectivity failed" -Source "HealthCheck"
}

# Get system information
$SystemInfo = Get-SystemInfo -IncludePerformance -IncludeDiskSpace
if ($SystemInfo.Performance.MemoryUsagePercent -gt 90) {
    Write-WarningLog -Message "High memory usage: $($SystemInfo.Performance.MemoryUsagePercent)%" -Source "HealthCheck"
}

# Monitor disk space
$DiskInfo = Get-DiskSpaceInfo -WarningThresholdPercent 20 -CriticalThresholdPercent 10
foreach ($Alert in $DiskInfo.Alerts) {
    if ($Alert.Level -eq 'Critical') {
        Send-ErrorWebhook -Message $Alert.Message -Source "DiskMonitor"
    }
}
```

### Utility Functions
```powershell
# Create temporary directories safely
$TempDir = New-TemporaryDirectory -Prefix "MyApp"
try {
    # Do work in temp directory
} finally {
    Remove-TemporaryDirectory -Path $TempDir -Force
}

# Generate random strings
$RandomPassword = Get-RandomString -Length 16 -IncludeSpecialChars
$SessionId = Get-RandomString -Length 8 -IncludeUppercase:$false -IncludeSpecialChars:$false

# Format file sizes
$FormattedSize = Format-FileSize -Bytes 1073741824  # Returns "1 GB"

# Check administrator privileges
if (Test-Administrator) {
    Write-InfoLog -Message "Running with elevated privileges" -Source "MyScript"
}
```

## Available Functions

### Logging Functions
- `Write-StandardLog` - Main logging function with customizable levels
- `Initialize-StandardLogging` - Configure logging system
- `Write-DebugLog` - Write debug messages
- `Write-InfoLog` - Write information messages  
- `Write-WarningLog` - Write warning messages
- `Write-ErrorLog` - Write error messages

### Error Handling Functions
- `Send-ErrorWebhook` - Send error notifications to webhooks
- `Send-NotificationWebhook` - Send general notifications
- `Invoke-SafeCommand` - Execute commands with error handling
- `New-StandardException` - Create standardized exceptions

### Configuration Functions
- `Get-StandardConfig` - Retrieve configuration values
- `Set-StandardConfig` - Set configuration values
- `Import-StandardConfig` - Load configuration from files
- `Export-StandardConfig` - Save configuration to files

### Network & System Functions
- `Test-NetworkConnectivity` - Test network connectivity
- `Test-WebEndpoint` - Test web endpoint availability
- `Get-SystemInfo` - Gather comprehensive system information
- `Get-DiskSpaceInfo` - Monitor disk space with alerts

### Utility Functions
- `ConvertTo-SecureString` / `ConvertFrom-SecureString` - Secure string handling
- `New-TemporaryDirectory` / `Remove-TemporaryDirectory` - Temp directory management
- `Format-FileSize` - Human-readable file size formatting
- `Get-RandomString` - Generate random strings
- `Test-Administrator` - Check for elevated privileges
- `Invoke-WithRetry` - Execute operations with retry logic

## Configuration

The module uses a centralized configuration system that supports multiple sources:

1. **Module Configuration** (in-memory, highest priority)
2. **Environment Variables** 
3. **Configuration Files** (JSON format)

### Default Configuration
```powershell
@{
    LogLevel = 'Information'
    LogPath = '%TEMP%\PS-Defaults'  # or /tmp/PS-Defaults on Unix
    WebhookUrl = $null
    MaxLogSize = 10MB
    LogRetentionDays = 30
}
```

### Webhook Configuration
Supports multiple webhook formats:

- **Slack**: Rich formatting with color-coded alerts
- **Microsoft Teams**: MessageCard format with structured information  
- **Generic**: Simple JSON format for custom integrations

## Examples

### Complete Monitoring Script
```powershell
# Import the module
Import-Module PS-Defaults

# Configure the environment
Set-StandardConfig -Key "WebhookUrl" -Value "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
Initialize-StandardLogging -LogPath "C:\Logs\Monitor" -RetentionDays 7

# Start monitoring
Write-InfoLog -Message "Starting system monitoring" -Source "Monitor"

try {
    # Test critical services
    $WebTest = Test-WebEndpoint -Uri "https://your-app.com/health" -ExpectedStatusCode 200
    if (-not $WebTest.Success) {
        Send-ErrorWebhook -Message "Web application health check failed" -Source "Monitor" -Environment "Production"
    }
    
    # Check disk space
    $DiskInfo = Get-DiskSpaceInfo -WarningThresholdPercent 15 -CriticalThresholdPercent 5
    foreach ($Alert in $DiskInfo.Alerts) {
        if ($Alert.Level -eq 'Critical') {
            Send-ErrorWebhook -Message $Alert.Message -Source "Monitor" -Environment "Production"
        } else {
            Send-NotificationWebhook -Message $Alert.Message -Level "Warning" -Source "Monitor"
        }
    }
    
    # Test database connectivity
    $DbTest = Invoke-SafeCommand -ScriptBlock {
        Test-NetworkConnectivity -ComputerName "your-db-server.com" -Port 1433
    } -ErrorAction SendWebhook -Source "DatabaseCheck"
    
    Write-InfoLog -Message "Monitoring cycle completed successfully" -Source "Monitor"
    
} catch {
    Write-ErrorLog -Message "Monitoring script failed: $($_.Exception.Message)" -Source "Monitor"
    Send-ErrorWebhook -ErrorRecord $_ -Source "Monitor" -Environment "Production"
}
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes following the existing code style
4. Add appropriate tests and documentation
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Changelog

### Version 1.0.0
- Initial release
- Standardized logging system
- Error handling and webhook notifications
- Configuration management
- Network and system utilities
- General utility functions 
