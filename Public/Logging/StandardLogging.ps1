function Write-StandardLog {
    <#
    .SYNOPSIS
    Writes a standardized log entry with timestamp, level, and message.

    .DESCRIPTION
    This function provides standardized logging functionality for PowerShell scripts.
    It writes to both the console and a log file with proper formatting.

    .PARAMETER Message
    The message to log.

    .PARAMETER Level
    The log level (Debug, Information, Warning, Error).

    .PARAMETER Source
    The source of the log message (script name, function name, etc.).

    .PARAMETER LogPath
    Optional custom log path. If not specified, uses the module default.

    .EXAMPLE
    Write-StandardLog -Message "Script started" -Level Information -Source "MyScript.ps1"

    .EXAMPLE
    Write-StandardLog -Message "Error occurred" -Level Error -Source "ProcessData"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Debug', 'Information', 'Warning', 'Error')]
        [string]$Level = 'Information',

        [Parameter(Mandatory = $false)]
        [string]$Source = 'PS-Defaults',

        [Parameter(Mandatory = $false)]
        [string]$LogPath
    )

    try {
        # Use module default log path if not specified
        if (-not $LogPath) {
            $LogPath = $Script:PSDefaultsConfig.LogPath
        }

        # Create timestamp
        $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        
        # Format log entry
        $LogEntry = "[$Timestamp] [$Level] [$Source] $Message"
        
        # Determine console logging behavior from configuration
        $consoleEnabled = $true
        if ($Script:PSDefaultsConfig.ContainsKey('ConsoleOutputEnabled')) {
            $consoleEnabled = [bool]$Script:PSDefaultsConfig.ConsoleOutputEnabled
        }
        $useErrorStream = $false
        if ($Script:PSDefaultsConfig.ContainsKey('UseErrorStreamForErrors')) {
            $useErrorStream = [bool]$Script:PSDefaultsConfig.UseErrorStreamForErrors
        }

        if ($consoleEnabled) {
            switch ($Level) {
                'Debug' {
                    # Respect DebugPreference when possible
                    Write-Debug $LogEntry
                }
                'Information' {
                    Write-Host $LogEntry -ForegroundColor White
                }
                'Warning' {
                    Write-Host $LogEntry -ForegroundColor Yellow
                }
                'Error' {
                    if ($useErrorStream) {
                        # Fallback to traditional error stream if explicitly requested
                        Write-Error $LogEntry
                    } else {
                        Write-Host $LogEntry -ForegroundColor Red
                    }
                }
            }
        }
        
        # Ensure log directory exists
        if (-not (Test-Path $LogPath)) {
            New-Item -Path $LogPath -ItemType Directory -Force | Out-Null
        }
        
        # Write to log file
        $LogFile = Join-Path -Path $LogPath -ChildPath "PS-Defaults-$(Get-Date -Format 'yyyy-MM-dd').log"
        Add-Content -Path $LogFile -Value $LogEntry -Encoding UTF8
        
        # Check log file size and rotate if necessary
        $LogFileInfo = Get-Item -Path $LogFile -ErrorAction SilentlyContinue
        if ($LogFileInfo -and $LogFileInfo.Length -gt $Script:PSDefaultsConfig.MaxLogSize) {
            $RotatedFile = Join-Path -Path $LogPath -ChildPath "PS-Defaults-$(Get-Date -Format 'yyyy-MM-dd-HHmmss').log"
            Move-Item -Path $LogFile -Destination $RotatedFile -Force
        }
        
    } catch {
        Write-Error "Failed to write log entry: $($_.Exception.Message)"
    }
}

function Initialize-StandardLogging {
    <#
    .SYNOPSIS
    Initializes the standard logging system.

    .DESCRIPTION
    Sets up the logging directory, cleans old log files, and configures logging parameters.

    .PARAMETER LogPath
    The path where log files will be stored.

    .PARAMETER MaxLogSize
    Maximum size of individual log files before rotation.

    .PARAMETER RetentionDays
    Number of days to retain log files.

    .EXAMPLE
    Initialize-StandardLogging -LogPath "C:\Logs\MyApp" -RetentionDays 7
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$LogPath,

        [Parameter(Mandatory = $false)]
        [long]$MaxLogSize = 10MB,

        [Parameter(Mandatory = $false)]
        [int]$RetentionDays = 30
    )

    try {
        if ($LogPath) {
            $Script:PSDefaultsConfig.LogPath = $LogPath
        }
        
        $Script:PSDefaultsConfig.MaxLogSize = $MaxLogSize
        $Script:PSDefaultsConfig.LogRetentionDays = $RetentionDays

        # Initialize new logging behavior config keys if absent
        if (-not $Script:PSDefaultsConfig.ContainsKey('ConsoleOutputEnabled')) {
            $Script:PSDefaultsConfig.ConsoleOutputEnabled = $true
        }
        if (-not $Script:PSDefaultsConfig.ContainsKey('UseErrorStreamForErrors')) {
            $Script:PSDefaultsConfig.UseErrorStreamForErrors = $false
        }
        
        # Ensure log directory exists
        if (-not (Test-Path $Script:PSDefaultsConfig.LogPath)) {
            New-Item -Path $Script:PSDefaultsConfig.LogPath -ItemType Directory -Force | Out-Null
        }
        
        # Clean up old log files
        $CutoffDate = (Get-Date).AddDays(-$RetentionDays)
        Get-ChildItem -Path $Script:PSDefaultsConfig.LogPath -Filter "*.log" | 
            Where-Object { $_.LastWriteTime -lt $CutoffDate } | 
            Remove-Item -Force -ErrorAction SilentlyContinue
        
        Write-StandardLog -Message "Logging system initialized" -Level Information -Source "Initialize-StandardLogging"
        
    } catch {
        Write-Error "Failed to initialize logging: $($_.Exception.Message)"
    }
}

function Write-DebugLog {
    <#
    .SYNOPSIS
    Writes a debug log entry.

    .PARAMETER Message
    The debug message to log.

    .PARAMETER Source
    The source of the log message.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [string]$Source = 'PS-Defaults'
    )

    Write-StandardLog -Message $Message -Level Debug -Source $Source
}

function Write-InfoLog {
    <#
    .SYNOPSIS
    Writes an information log entry.

    .PARAMETER Message
    The information message to log.

    .PARAMETER Source
    The source of the log message.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [string]$Source = 'PS-Defaults'
    )

    Write-StandardLog -Message $Message -Level Information -Source $Source
}

function Write-WarningLog {
    <#
    .SYNOPSIS
    Writes a warning log entry.

    .PARAMETER Message
    The warning message to log.

    .PARAMETER Source
    The source of the log message.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [string]$Source = 'PS-Defaults'
    )

    Write-StandardLog -Message $Message -Level Warning -Source $Source
}

function Write-ErrorLog {
    <#
    .SYNOPSIS
    Writes an error log entry.

    .PARAMETER Message
    The error message to log.

    .PARAMETER Source
    The source of the log message.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [string]$Source = 'PS-Defaults'
    )

    Write-StandardLog -Message $Message -Level Error -Source $Source
}