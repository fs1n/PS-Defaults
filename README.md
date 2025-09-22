# PS-Defaults

A modular PowerShell framework that standardizes repeating script functions for IT environments. This framework provides a pluggable architecture where you can import only the functionality you need, avoiding system bloat while maintaining consistency across all PowerShell scripts in your IT environment.

## 🔧 **Modular Architecture**

PS-Defaults now features a modular design with separate modules for specific functionality:

- **`PS-Defaults`** - Main module that loads `PS-Defaults.Default` for backward compatibility
- **`PS-Defaults.Default`** - Core functionality (logging, configuration, error handling, utilities)
- **`PS-Defaults.AdvancedLogging`** - Enhanced logging with analysis and structured logging
- **`PS-Defaults.Networking`** - Network connectivity testing and monitoring
- **`PS-Defaults.System`** - System information gathering and monitoring

### Usage Examples

```powershell
# Load all core functions (backward compatible)
Import-Module PS-Defaults

# Load only core functions explicitly
Import-Module PS-Defaults.Default

# Load core + advanced logging features
Import-Module PS-Defaults.Default
Import-Module PS-Defaults.AdvancedLogging

# Load specific modules as needed
Import-Module PS-Defaults.Networking
Import-Module PS-Defaults.System
```

## Features

### 🔍 **Standardized Logging** (PS-Defaults.Default)
- Consistent log formatting with timestamps, levels, and sources
- Automatic log rotation and retention management
- Multiple log levels (Debug, Information, Warning, Error)
- File and console output

### 📊 **Advanced Logging** (PS-Defaults.AdvancedLogging)
- Detailed logging with performance metrics and stack traces
- Log analysis and reporting (HTML, JSON, CSV formats)
- Structured JSON logging for better parsing
- Log session management with metrics tracking
- Log forwarding to external systems
- Custom log formatting options

### 🚨 **Error Handling & Webhooks** (PS-Defaults.Default)
- Standardized error reporting to webhooks (Slack, Teams, Generic)
- Safe command execution with retry logic
- Custom exception creation with additional context
- Automatic error logging and notification

### ⚙️ **Configuration Management** (PS-Defaults.Default)
- Centralized configuration system
- Support for multiple configuration sources (Module, Environment, Files)
- JSON configuration file support
- Nested configuration keys with dot notation

### 🌐 **Network & System Utilities**
- **PS-Defaults.Networking**: Network connectivity testing (ping, port, DNS), Web endpoint health checks
- **PS-Defaults.System**: Comprehensive system information gathering, Disk space monitoring with alerts

### 🛠️ **General Utilities** (PS-Defaults.Default)
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
   
   # Import the main module (loads PS-Defaults.Default automatically)
   Import-Module ".\PS-Defaults\PS-Defaults.psd1"
   
   # Or import specific modules as needed
   Import-Module ".\PS-Defaults\PS-Defaults.Default.psd1"
   Import-Module ".\PS-Defaults\PS-Defaults.AdvancedLogging.psd1"
   Import-Module ".\PS-Defaults\PS-Defaults.Networking.psd1"
   Import-Module ".\PS-Defaults\PS-Defaults.System.psd1"
   ```

2. **Add to PowerShell Profile:**
   ```powershell
   # Add to your PowerShell profile for automatic loading
   Import-Module "C:\Path\To\PS-Defaults\PS-Defaults.psd1"
   ```

## CI/CD Automation

PS-Defaults includes automated publishing to PowerShell Gallery using GitHub Actions.

### Automated Publishing Setup

1. **Get PowerShell Gallery API Key**: Log into [PowerShell Gallery](https://www.powershellgallery.com/) → Profile → API Keys → Create new key
2. **Add Repository Secret**: Go to repository Settings → Secrets → Actions → Add `PSGALLERY_API_KEY`
3. **Create Release**: The workflow automatically publishes to PowerShell Gallery when you create a GitHub release

### Workflow Features

- ✅ **Automated Testing**: Validates module manifest and imports on every push
- ✅ **PowerShell Gallery Publishing**: Publishes on release creation only
- ✅ **Security**: API key stored safely in GitHub secrets
- ✅ **Validation**: Ensures module compliance before publishing

For detailed setup instructions, see [`.github/PUBLISHING.md`](.github/PUBLISHING.md).

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

### Advanced Logging with Enhanced Features
```powershell
# Import advanced logging module
Import-Module PS-Defaults.Default
Import-Module PS-Defaults.AdvancedLogging

# Start a logging session with performance tracking
Start-LogSession -SessionName "DataProcessing" -TrackPerformance

# Write detailed logs with performance metrics
Write-DetailedLog -Message "Processing started" -Level Information -Source "DataProcessor" -Category "Performance" -IncludePerformanceData

# Write structured JSON logs
Write-StructuredLog -Message "User login" -Level Information -Source "Auth" -CustomFields @{
    UserId = "12345"
    IPAddress = "192.168.1.100"
    UserAgent = "PowerShell"
}

# Stop session and get metrics
$SessionMetrics = Stop-LogSession -SessionName "DataProcessing"
Write-Host "Session completed in $($SessionMetrics.Duration)"

# Analyze logs and generate reports
$Analysis = Get-LogAnalysis -LogPath "C:\Logs\MyApp"
Export-LogReport -LogPath "C:\Logs\MyApp" -OutputPath "C:\Reports\LogReport.html" -Format HTML
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

### Core Logging Functions (PS-Defaults.Default)
- `Write-StandardLog` - Main logging function with customizable levels
- `Initialize-StandardLogging` - Configure logging system
- `Write-DebugLog` - Write debug messages
- `Write-InfoLog` - Write information messages  
- `Write-WarningLog` - Write warning messages
- `Write-ErrorLog` - Write error messages

### Advanced Logging Functions (PS-Defaults.AdvancedLogging)
- `Write-DetailedLog` - Enhanced logging with performance metrics and stack traces
- `Get-LogAnalysis` - Analyze log files and provide statistical information
- `Export-LogReport` - Generate comprehensive reports in HTML, JSON, or CSV format
- `Set-AdvancedLogFormat` - Configure advanced logging formats (JSON, custom templates)
- `Start-LogSession` / `Stop-LogSession` - Manage logging sessions with tracking
- `Get-LogMetrics` - Get detailed metrics from logging sessions
- `Write-StructuredLog` - Write structured JSON log entries with custom fields
- `Enable-LogForwarding` / `Disable-LogForwarding` - Configure log forwarding to external systems

### Error Handling Functions (PS-Defaults.Default)
- `Send-ErrorWebhook` - Send error notifications to webhooks
- `Send-NotificationWebhook` - Send general notifications
- `Invoke-SafeCommand` - Execute commands with error handling
- `New-StandardException` - Create standardized exceptions

### Configuration Functions (PS-Defaults.Default)
- `Get-StandardConfig` - Retrieve configuration values
- `Set-StandardConfig` - Set configuration values
- `Import-StandardConfig` - Load configuration from files
- `Export-StandardConfig` - Save configuration to files

### Network Functions (PS-Defaults.Networking)
- `Test-NetworkConnectivity` - Test network connectivity
- `Test-WebEndpoint` - Test web endpoint availability

### System Functions (PS-Defaults.System)
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

## Module Selection Guide

### When to Use Each Module

**PS-Defaults (Main Module)**
- Use when you need backward compatibility with existing scripts
- Automatically loads PS-Defaults.Default for full compatibility
- Perfect for legacy implementations

**PS-Defaults.Default** 
- Use for core functionality without bloat
- Includes: logging, configuration, error handling, utilities
- Best for: scripts that need basic standardization
- Memory footprint: ~22 functions

**PS-Defaults.AdvancedLogging**
- Use when you need detailed logging and analysis
- Includes: session management, structured logging, HTML/CSV reports
- Best for: production monitoring, debugging, audit trails
- Requires: PS-Defaults.Default
- Additional functions: 10 advanced logging functions

**PS-Defaults.Networking**
- Use for network-focused scripts and monitoring
- Includes: connectivity testing, endpoint monitoring
- Best for: network administration, health checks
- Standalone module: 2 specialized functions

**PS-Defaults.System**
- Use for system administration and monitoring
- Includes: system information, disk monitoring
- Best for: system health checks, inventory scripts  
- Standalone module: 2 specialized functions

### Benefits of Modular Architecture

1. **Reduced Memory Footprint**: Import only what you need
2. **Clear Separation of Concerns**: Each module has a specific purpose
3. **Enhanced Functionality**: Advanced modules provide powerful features without bloating core module
4. **Backward Compatibility**: Existing scripts continue to work unchanged
5. **Future Extensibility**: Easy to add new specialized modules
6. **Better Organization**: Functions are logically grouped by purpose

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes following the existing code style
4. Add appropriate tests and documentation
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Changelog

### Version 1.0.0 (Modular Release)
- **NEW**: Modular architecture with pluggable functionality
- **NEW**: PS-Defaults.Default module with core functions (22 functions)
- **NEW**: PS-Defaults.AdvancedLogging module with enhanced logging features (10 functions)
  - Log session management with performance tracking
  - Log analysis and reporting (HTML, CSV, JSON formats)
  - Structured JSON logging with custom fields
  - Log forwarding to external systems
- **NEW**: PS-Defaults.Networking module for network utilities (2 functions)
- **NEW**: PS-Defaults.System module for system monitoring (2 functions)
- **IMPROVED**: Backward compatibility maintained - existing scripts work unchanged
- **IMPROVED**: Reduced memory footprint when using selective module loading
- **IMPROVED**: Clear separation of concerns across modules
- Standardized logging system
- Error handling and webhook notifications
- Configuration management
- Network and system utilities
- General utility functions 
