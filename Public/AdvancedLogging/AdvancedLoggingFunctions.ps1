function Write-DetailedLog {
    <#
    .SYNOPSIS
    Writes detailed log entries with enhanced formatting and metadata.

    .DESCRIPTION
    Advanced logging function that provides detailed information including caller context,
    execution time, memory usage, and custom formatting options.

    .PARAMETER Message
    The message to log.

    .PARAMETER Level
    The log level (Debug, Information, Warning, Error, Critical).

    .PARAMETER Source
    The source of the log message.

    .PARAMETER Category
    Optional category for log classification.

    .PARAMETER IncludeStackTrace
    Include stack trace information in the log.

    .PARAMETER IncludePerformanceData
    Include performance metrics (memory, CPU) in the log.

    .EXAMPLE
    Write-DetailedLog -Message "Processing started" -Level Information -Source "DataProcessor" -Category "Performance" -IncludePerformanceData
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Debug', 'Information', 'Warning', 'Error', 'Critical')]
        [string]$Level = 'Information',

        [Parameter(Mandatory = $false)]
        [string]$Source = 'PS-Defaults-Advanced',

        [Parameter(Mandatory = $false)]
        [string]$Category,

        [Parameter(Mandatory = $false)]
        [switch]$IncludeStackTrace,

        [Parameter(Mandatory = $false)]
        [switch]$IncludePerformanceData
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
    $logEntry = "[$timestamp] [$Level] [$Source]"
    
    if ($Category) {
        $logEntry += " [$Category]"
    }
    
    $logEntry += " $Message"

    if ($IncludePerformanceData) {
        $memoryUsage = [System.GC]::GetTotalMemory($false) / 1MB
        $logEntry += " | Memory: $([math]::Round($memoryUsage, 2))MB"
    }

    if ($IncludeStackTrace) {
        $stack = Get-PSCallStack | Select-Object -Skip 1 -First 3
        $logEntry += " | CallStack: $($stack.Command -join ' -> ')"
    }

    Write-StandardLog -Message $logEntry -Level $Level -Source $Source
}

function Get-LogAnalysis {
    <#
    .SYNOPSIS
    Analyzes log files and provides statistical information.

    .DESCRIPTION
    Parses log files and provides analysis including error rates, message frequency,
    source statistics, and time-based patterns.

    .PARAMETER LogPath
    Path to the log file or directory to analyze.

    .PARAMETER StartDate
    Start date for analysis filter.

    .PARAMETER EndDate
    End date for analysis filter.

    .EXAMPLE
    Get-LogAnalysis -LogPath "C:\Logs\MyApp" -StartDate (Get-Date).AddDays(-7)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$LogPath,

        [Parameter(Mandatory = $false)]
        [DateTime]$StartDate,

        [Parameter(Mandatory = $false)]
        [DateTime]$EndDate
    )

    if (-not $LogPath) {
        $LogPath = $Script:PSDefaultsConfig.LogPath
    }

    $analysis = @{
        TotalEntries = 0
        ErrorCount = 0
        WarningCount = 0
        InfoCount = 0
        DebugCount = 0
        Sources = @{}
        TimeRange = @{}
        ErrorRate = 0
    }

    try {
        if (Test-Path $LogPath -PathType Container) {
            $logFiles = Get-ChildItem -Path $LogPath -Filter "*.log" -Recurse
        } else {
            $logFiles = @(Get-Item $LogPath)
        }

        foreach ($file in $logFiles) {
            $content = Get-Content $file.FullName
            foreach ($line in $content) {
                if ($line -match '\[(.*?)\] \[(.*?)\] \[(.*?)\]') {
                    $timestamp = $matches[1]
                    $level = $matches[2]
                    $source = $matches[3]

                    $analysis.TotalEntries++
                    
                    switch ($level) {
                        'Error' { $analysis.ErrorCount++ }
                        'Warning' { $analysis.WarningCount++ }
                        'Information' { $analysis.InfoCount++ }
                        'Debug' { $analysis.DebugCount++ }
                    }

                    if (-not $analysis.Sources.ContainsKey($source)) {
                        $analysis.Sources[$source] = 0
                    }
                    $analysis.Sources[$source]++
                }
            }
        }

        if ($analysis.TotalEntries -gt 0) {
            $analysis.ErrorRate = [math]::Round(($analysis.ErrorCount / $analysis.TotalEntries) * 100, 2)
        }

        return $analysis
    } catch {
        Write-ErrorLog -Message "Failed to analyze logs: $($_.Exception.Message)" -Source "Get-LogAnalysis"
        throw
    }
}

function Export-LogReport {
    <#
    .SYNOPSIS
    Exports a comprehensive log report to various formats.

    .DESCRIPTION
    Creates detailed reports from log analysis in HTML, JSON, or CSV format.

    .PARAMETER LogPath
    Path to the log file or directory to analyze.

    .PARAMETER OutputPath
    Path where the report will be saved.

    .PARAMETER Format
    Output format (HTML, JSON, CSV).

    .EXAMPLE
    Export-LogReport -LogPath "C:\Logs\MyApp" -OutputPath "C:\Reports\LogReport.html" -Format HTML
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$LogPath,

        [Parameter(Mandatory = $true)]
        [string]$OutputPath,

        [Parameter(Mandatory = $false)]
        [ValidateSet('HTML', 'JSON', 'CSV')]
        [string]$Format = 'HTML'
    )

    $analysis = Get-LogAnalysis -LogPath $LogPath
    
    switch ($Format) {
        'JSON' {
            $analysis | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputPath -Encoding UTF8
        }
        'CSV' {
            $csvData = @()
            $csvData += [PSCustomObject]@{
                Metric = 'Total Entries'
                Value = $analysis.TotalEntries
            }
            $csvData += [PSCustomObject]@{
                Metric = 'Error Count'
                Value = $analysis.ErrorCount
            }
            $csvData += [PSCustomObject]@{
                Metric = 'Warning Count'
                Value = $analysis.WarningCount
            }
            $csvData += [PSCustomObject]@{
                Metric = 'Error Rate %'
                Value = $analysis.ErrorRate
            }
            $csvData | Export-Csv -Path $OutputPath -NoTypeInformation
        }
        'HTML' {
            $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>PS-Defaults Log Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .metric { margin: 10px 0; }
        .error { color: red; }
        .warning { color: orange; }
        .info { color: blue; }
    </style>
</head>
<body>
    <h1>PS-Defaults Log Analysis Report</h1>
    <div class="metric">Total Entries: <strong>$($analysis.TotalEntries)</strong></div>
    <div class="metric error">Error Count: <strong>$($analysis.ErrorCount)</strong></div>
    <div class="metric warning">Warning Count: <strong>$($analysis.WarningCount)</strong></div>
    <div class="metric info">Information Count: <strong>$($analysis.InfoCount)</strong></div>
    <div class="metric">Error Rate: <strong>$($analysis.ErrorRate)%</strong></div>
    <h2>Sources</h2>
    <ul>
"@
            foreach ($source in $analysis.Sources.Keys) {
                $html += "<li>$source`: $($analysis.Sources[$source]) entries</li>`n"
            }
            $html += @"
    </ul>
    <p><em>Report generated: $(Get-Date)</em></p>
</body>
</html>
"@
            $html | Out-File -FilePath $OutputPath -Encoding UTF8
        }
    }

    Write-InfoLog -Message "Log report exported to: $OutputPath" -Source "Export-LogReport"
}

function Set-AdvancedLogFormat {
    <#
    .SYNOPSIS
    Sets advanced formatting options for logging.

    .DESCRIPTION
    Configures advanced logging format including JSON structured logging,
    custom templates, and formatting options.

    .PARAMETER Format
    Log format type (Standard, JSON, Custom).

    .PARAMETER Template
    Custom log format template.

    .EXAMPLE
    Set-AdvancedLogFormat -Format JSON
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('Standard', 'JSON', 'Custom')]
        [string]$Format,

        [Parameter(Mandatory = $false)]
        [string]$Template
    )

    $Script:AdvancedLogConfig.LogFormat = $Format
    
    if ($Template) {
        $Script:AdvancedLogConfig.CustomTemplate = $Template
    }

    Write-InfoLog -Message "Advanced log format set to: $Format" -Source "Set-AdvancedLogFormat"
}

function Start-LogSession {
    <#
    .SYNOPSIS
    Starts a new logging session with enhanced tracking.

    .DESCRIPTION
    Creates a new logging session that tracks all log entries, performance metrics,
    and provides session-based analysis.

    .PARAMETER SessionName
    Name of the logging session.

    .PARAMETER TrackPerformance
    Whether to track performance metrics during the session.

    .EXAMPLE
    Start-LogSession -SessionName "DataProcessing" -TrackPerformance
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SessionName,

        [Parameter(Mandatory = $false)]
        [switch]$TrackPerformance
    )

    $session = @{
        Name = $SessionName
        StartTime = Get-Date
        LogEntries = @()
        TrackPerformance = $TrackPerformance.IsPresent
        StartMemory = if ($TrackPerformance) { [System.GC]::GetTotalMemory($false) } else { 0 }
    }

    $Script:LogSessions[$SessionName] = $session
    $Script:AdvancedLogConfig.SessionEnabled = $true
    $Script:AdvancedLogConfig.CurrentSession = $SessionName

    Write-InfoLog -Message "Log session '$SessionName' started" -Source "Start-LogSession"
}

function Stop-LogSession {
    <#
    .SYNOPSIS
    Stops a logging session and provides summary information.

    .DESCRIPTION
    Ends a logging session and provides analysis of all log entries,
    performance metrics, and session statistics.

    .PARAMETER SessionName
    Name of the logging session to stop.

    .EXAMPLE
    Stop-LogSession -SessionName "DataProcessing"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SessionName
    )

    if ($Script:LogSessions.ContainsKey($SessionName)) {
        $session = $Script:LogSessions[$SessionName]
        $session.EndTime = Get-Date
        $session.Duration = $session.EndTime - $session.StartTime

        $summary = @{
            SessionName = $SessionName
            Duration = $session.Duration
            LogEntryCount = $session.LogEntries.Count
        }

        if ($session.TrackPerformance) {
            $endMemory = [System.GC]::GetTotalMemory($false)
            $summary.MemoryDelta = ($endMemory - $session.StartMemory) / 1MB
        }

        Write-InfoLog -Message "Log session '$SessionName' completed. Duration: $($session.Duration), Entries: $($session.LogEntries.Count)" -Source "Stop-LogSession"
        
        $Script:AdvancedLogConfig.SessionEnabled = $false
        $Script:AdvancedLogConfig.CurrentSession = $null

        return $summary
    } else {
        Write-WarningLog -Message "Log session '$SessionName' not found" -Source "Stop-LogSession"
    }
}

function Get-LogMetrics {
    <#
    .SYNOPSIS
    Gets detailed metrics from current or specified log session.

    .DESCRIPTION
    Provides comprehensive metrics and statistics for logging sessions
    including entry counts, performance data, and time analysis.

    .PARAMETER SessionName
    Name of the session to analyze. If not specified, uses current session.

    .EXAMPLE
    Get-LogMetrics -SessionName "DataProcessing"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$SessionName
    )

    if (-not $SessionName) {
        $SessionName = $Script:AdvancedLogConfig.CurrentSession
    }

    if ($SessionName -and $Script:LogSessions.ContainsKey($SessionName)) {
        $session = $Script:LogSessions[$SessionName]
        
        $metrics = @{
            SessionName = $SessionName
            IsActive = ($Script:AdvancedLogConfig.CurrentSession -eq $SessionName)
            StartTime = $session.StartTime
            LogEntryCount = $session.LogEntries.Count
            TrackingPerformance = $session.TrackPerformance
        }

        if ($session.EndTime) {
            $metrics.EndTime = $session.EndTime
            $metrics.Duration = $session.Duration
        } else {
            $metrics.CurrentDuration = (Get-Date) - $session.StartTime
        }

        return $metrics
    } else {
        Write-WarningLog -Message "No active session or session '$SessionName' not found" -Source "Get-LogMetrics"
        return $null
    }
}

function Write-StructuredLog {
    <#
    .SYNOPSIS
    Writes structured log entries in JSON format.

    .DESCRIPTION
    Creates structured log entries with additional metadata, custom fields,
    and JSON formatting for better parsing and analysis.

    .PARAMETER Message
    The log message.

    .PARAMETER Level
    The log level.

    .PARAMETER Source
    The log source.

    .PARAMETER CustomFields
    Hashtable of custom fields to include in the structured log.

    .EXAMPLE
    Write-StructuredLog -Message "User login" -Level Information -Source "Auth" -CustomFields @{UserId="123"; IP="192.168.1.1"}
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Debug', 'Information', 'Warning', 'Error')]
        [string]$Level = 'Information',

        [Parameter(Mandatory = $false)]
        [string]$Source = 'PS-Defaults-Structured',

        [Parameter(Mandatory = $false)]
        [hashtable]$CustomFields = @{}
    )

    $structuredEntry = @{
        timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
        level = $Level
        source = $Source
        message = $Message
    }

    foreach ($key in $CustomFields.Keys) {
        $structuredEntry[$key] = $CustomFields[$key]
    }

    $jsonLog = $structuredEntry | ConvertTo-Json -Compress

    Write-StandardLog -Message $jsonLog -Level $Level -Source $Source
}

function Enable-LogForwarding {
    <#
    .SYNOPSIS
    Enables log forwarding to external systems.

    .DESCRIPTION
    Configures log forwarding to external endpoints such as log aggregation
    services, SIEM systems, or custom webhooks.

    .PARAMETER Endpoint
    The endpoint URL for log forwarding.

    .PARAMETER ApiKey
    Optional API key for authentication.

    .EXAMPLE
    Enable-LogForwarding -Endpoint "https://logs.example.com/api/logs" -ApiKey "secret123"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Endpoint,

        [Parameter(Mandatory = $false)]
        [string]$ApiKey
    )

    $Script:AdvancedLogConfig.ForwardingEnabled = $true
    $Script:AdvancedLogConfig.ForwardingEndpoint = $Endpoint
    
    if ($ApiKey) {
        $Script:AdvancedLogConfig.ForwardingApiKey = $ApiKey
    }

    Write-InfoLog -Message "Log forwarding enabled to: $Endpoint" -Source "Enable-LogForwarding"
}

function Disable-LogForwarding {
    <#
    .SYNOPSIS
    Disables log forwarding.

    .DESCRIPTION
    Disables log forwarding to external systems.

    .EXAMPLE
    Disable-LogForwarding
    #>
    [CmdletBinding()]
    param()

    $Script:AdvancedLogConfig.ForwardingEnabled = $false
    $Script:AdvancedLogConfig.ForwardingEndpoint = $null
    $Script:AdvancedLogConfig.ForwardingApiKey = $null

    Write-InfoLog -Message "Log forwarding disabled" -Source "Disable-LogForwarding"
}