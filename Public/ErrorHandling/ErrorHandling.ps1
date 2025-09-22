function Send-ErrorWebhook {
    <#
    .SYNOPSIS
    Sends error information to a configured webhook endpoint.

    .DESCRIPTION
    This function sends error details to a webhook for centralized error monitoring.
    Supports various webhook formats including Slack, Teams, and generic JSON.

    .PARAMETER ErrorRecord
    The PowerShell error record to send.

    .PARAMETER Message
    Custom error message to include.

    .PARAMETER WebhookUrl
    The webhook URL to send the error to. If not specified, uses module configuration.

    .PARAMETER WebhookType
    The type of webhook (Slack, Teams, Generic).

    .PARAMETER Source
    The source script or function name.

    .PARAMETER Environment
    The environment where the error occurred (Dev, Test, Prod).

    .EXAMPLE
    Send-ErrorWebhook -ErrorRecord $Error[0] -Source "MyScript.ps1" -Environment "Prod"

    .EXAMPLE
    Send-ErrorWebhook -Message "Custom error occurred" -WebhookType "Slack" -Source "DataProcessor"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [System.Management.Automation.ErrorRecord]$ErrorRecord,

        [Parameter(Mandatory = $false)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [string]$WebhookUrl,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Slack', 'Teams', 'Generic')]
        [string]$WebhookType = 'Generic',

        [Parameter(Mandatory = $false)]
        [string]$Source = 'PS-Defaults',

        [Parameter(Mandatory = $false)]
        [ValidateSet('Dev', 'Test', 'Prod')]
        [string]$Environment = 'Unknown'
    )

    try {
        # Use module webhook URL if not specified
        if (-not $WebhookUrl) {
            $WebhookUrl = $Script:PSDefaultsConfig.WebhookUrl
        }

        if (-not $WebhookUrl) {
            Write-WarningLog -Message "No webhook URL configured. Cannot send error notification." -Source "Send-ErrorWebhook"
            return
        }

        # Prepare error details
        $ErrorDetails = @{
            Timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")
            Source = $Source
            Environment = $Environment
            ComputerName = $env:COMPUTERNAME
            UserName = $env:USERNAME
        }

        if ($ErrorRecord) {
            $ErrorDetails.ErrorMessage = $ErrorRecord.Exception.Message
            $ErrorDetails.ErrorType = $ErrorRecord.Exception.GetType().Name
            $ErrorDetails.ScriptStackTrace = $ErrorRecord.ScriptStackTrace
            $ErrorDetails.FullyQualifiedErrorId = $ErrorRecord.FullyQualifiedErrorId
        }

        if ($Message) {
            $ErrorDetails.CustomMessage = $Message
        }

        # Format payload based on webhook type
        $Payload = switch ($WebhookType) {
            'Slack' {
                @{
                    text = "❌ Error Alert: $Environment"
                    attachments = @(
                        @{
                            color = "danger"
                            fields = @(
                                @{ title = "Source"; value = $Source; short = $true }
                                @{ title = "Environment"; value = $Environment; short = $true }
                                @{ title = "Computer"; value = $env:COMPUTERNAME; short = $true }
                                @{ title = "Timestamp"; value = $ErrorDetails.Timestamp; short = $true }
                            )
                            text = if ($ErrorRecord) { $ErrorRecord.Exception.Message } else { $Message }
                        }
                    )
                }
            }
            'Teams' {
                @{
                    "@type" = "MessageCard"
                    "@context" = "http://schema.org/extensions"
                    themeColor = "FF0000"
                    summary = "Error Alert: $Environment"
                    sections = @(
                        @{
                            activityTitle = "❌ Error Alert"
                            activitySubtitle = $Environment
                            facts = @(
                                @{ name = "Source"; value = $Source }
                                @{ name = "Environment"; value = $Environment }
                                @{ name = "Computer"; value = $env:COMPUTERNAME }
                                @{ name = "Timestamp"; value = $ErrorDetails.Timestamp }
                            )
                            text = if ($ErrorRecord) { $ErrorRecord.Exception.Message } else { $Message }
                        }
                    )
                }
            }
            'Generic' {
                @{
                    alert_type = "error"
                    title = "PowerShell Error Alert"
                    details = $ErrorDetails
                }
            }
        }

        # Convert to JSON
        $JsonPayload = $Payload | ConvertTo-Json -Depth 10

        # Send webhook
        $Headers = @{
            'Content-Type' = 'application/json'
        }

        $Response = Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $JsonPayload -Headers $Headers -ErrorAction Stop
        
        Write-InfoLog -Message "Error webhook sent successfully" -Source "Send-ErrorWebhook"
        
    } catch {
        Write-ErrorLog -Message "Failed to send error webhook: $($_.Exception.Message)" -Source "Send-ErrorWebhook"
    }
}

function Send-NotificationWebhook {
    <#
    .SYNOPSIS
    Sends a general notification to a webhook endpoint.

    .DESCRIPTION
    Sends informational notifications to configured webhooks for monitoring and alerting.

    .PARAMETER Message
    The notification message to send.

    .PARAMETER Title
    Optional title for the notification.

    .PARAMETER Level
    The notification level (Info, Warning, Success).

    .PARAMETER WebhookUrl
    The webhook URL. If not specified, uses module configuration.

    .PARAMETER WebhookType
    The type of webhook format.

    .PARAMETER Source
    The source of the notification.

    .EXAMPLE
    Send-NotificationWebhook -Message "Backup completed successfully" -Level "Success" -Source "BackupScript"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [string]$Title,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Info', 'Warning', 'Success')]
        [string]$Level = 'Info',

        [Parameter(Mandatory = $false)]
        [string]$WebhookUrl,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Slack', 'Teams', 'Generic')]
        [string]$WebhookType = 'Generic',

        [Parameter(Mandatory = $false)]
        [string]$Source = 'PS-Defaults'
    )

    try {
        if (-not $WebhookUrl) {
            $WebhookUrl = $Script:PSDefaultsConfig.WebhookUrl
        }

        if (-not $WebhookUrl) {
            Write-WarningLog -Message "No webhook URL configured. Cannot send notification." -Source "Send-NotificationWebhook"
            return
        }

        # Determine color/emoji based on level
        $ColorMap = @{
            'Info' = @{ Color = '0078D4'; Emoji = 'ℹ️' }
            'Warning' = @{ Color = 'FF8C00'; Emoji = '⚠️' }
            'Success' = @{ Color = '00B294'; Emoji = '✅' }
        }

        $LevelInfo = $ColorMap[$Level]
        $DisplayTitle = if ($Title) { $Title } else { "$($LevelInfo.Emoji) $Level Notification" }

        # Format payload based on webhook type
        $Payload = switch ($WebhookType) {
            'Slack' {
                @{
                    text = $DisplayTitle
                    attachments = @(
                        @{
                            color = $LevelInfo.Color
                            fields = @(
                                @{ title = "Source"; value = $Source; short = $true }
                                @{ title = "Timestamp"; value = (Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC"); short = $true }
                            )
                            text = $Message
                        }
                    )
                }
            }
            'Teams' {
                @{
                    "@type" = "MessageCard"
                    "@context" = "http://schema.org/extensions"
                    themeColor = $LevelInfo.Color.TrimStart('#')
                    summary = $DisplayTitle
                    sections = @(
                        @{
                            activityTitle = $DisplayTitle
                            facts = @(
                                @{ name = "Source"; value = $Source }
                                @{ name = "Timestamp"; value = (Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC") }
                            )
                            text = $Message
                        }
                    )
                }
            }
            'Generic' {
                @{
                    notification_type = $Level.ToLower()
                    title = $DisplayTitle
                    message = $Message
                    source = $Source
                    timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")
                    computer = $env:COMPUTERNAME
                }
            }
        }

        $JsonPayload = $Payload | ConvertTo-Json -Depth 10
        $Headers = @{ 'Content-Type' = 'application/json' }

        $Response = Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $JsonPayload -Headers $Headers -ErrorAction Stop
        
        Write-InfoLog -Message "Notification webhook sent successfully" -Source "Send-NotificationWebhook"
        
    } catch {
        Write-ErrorLog -Message "Failed to send notification webhook: $($_.Exception.Message)" -Source "Send-NotificationWebhook"
    }
}

function Invoke-SafeCommand {
    <#
    .SYNOPSIS
    Executes a script block with standardized error handling.

    .DESCRIPTION
    Provides a wrapper for executing commands with automatic error logging and optional webhook notifications.

    .PARAMETER ScriptBlock
    The script block to execute safely.

    .PARAMETER OnError
    What to do when an error occurs (Continue, Stop, SendWebhook).

    .PARAMETER Source
    The source identifier for logging.

    .PARAMETER RetryCount
    Number of times to retry on failure.

    .PARAMETER RetryDelay
    Delay between retries in seconds.

    .EXAMPLE
    Invoke-SafeCommand -ScriptBlock { Get-Process } -Source "ProcessCheck"

    .EXAMPLE
    Invoke-SafeCommand -ScriptBlock { 
        # Some risky operation
        Invoke-RestMethod -Uri "https://api.example.com/data"
    } -OnError SendWebhook -RetryCount 3 -Source "APICall"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [scriptblock]$ScriptBlock,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Continue', 'Stop', 'SendWebhook')]
        [string]$OnError = 'Continue',

        [Parameter(Mandatory = $false)]
        [string]$Source = 'PS-Defaults',

        [Parameter(Mandatory = $false)]
        [int]$RetryCount = 0,

        [Parameter(Mandatory = $false)]
        [int]$RetryDelay = 5
    )

    $Attempt = 0
    $MaxAttempts = $RetryCount + 1

    do {
        $Attempt++
        try {
            Write-DebugLog -Message "Executing command (attempt $Attempt of $MaxAttempts)" -Source $Source
            
            $Result = & $ScriptBlock
            
            if ($Attempt -gt 1) {
                Write-InfoLog -Message "Command succeeded on attempt $Attempt" -Source $Source
            }
            
            return $Result
            
        } catch {
            $ErrorMessage = "Command failed on attempt $Attempt`: $($_.Exception.Message)"
            Write-ErrorLog -Message $ErrorMessage -Source $Source
            
            if ($OnError -eq 'SendWebhook') {
                Send-ErrorWebhook -ErrorRecord $_ -Source $Source
            }
            
            if ($Attempt -lt $MaxAttempts) {
                Write-InfoLog -Message "Retrying in $RetryDelay seconds..." -Source $Source
                Start-Sleep -Seconds $RetryDelay
            } else {
                if ($OnError -eq 'Stop') {
                    throw $_
                }
                return $null
            }
        }
    } while ($Attempt -lt $MaxAttempts)
}

function New-StandardException {
    <#
    .SYNOPSIS
    Creates a standardized exception with additional context.

    .DESCRIPTION
    Creates a custom exception with standardized format and additional diagnostic information.

    .PARAMETER Message
    The exception message.

    .PARAMETER ErrorCode
    Optional error code.

    .PARAMETER Source
    The source of the exception.

    .PARAMETER InnerException
    An inner exception if applicable.

    .EXAMPLE
    throw (New-StandardException -Message "Configuration file not found" -ErrorCode "CFG001" -Source "LoadConfig")
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [string]$ErrorCode,

        [Parameter(Mandatory = $false)]
        [string]$Source = 'PS-Defaults',

        [Parameter(Mandatory = $false)]
        [System.Exception]$InnerException
    )

    $FullMessage = "[$Source]"
    if ($ErrorCode) {
        $FullMessage += " [$ErrorCode]"
    }
    $FullMessage += " $Message"

    if ($InnerException) {
        return [System.Exception]::new($FullMessage, $InnerException)
    } else {
        return [System.Exception]::new($FullMessage)
    }
}