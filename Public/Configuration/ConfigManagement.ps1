function Get-StandardConfig {
    <#
    .SYNOPSIS
    Retrieves configuration values from the standard configuration system.

    .DESCRIPTION
    Gets configuration values from JSON files, environment variables, or the module's internal configuration.

    .PARAMETER Key
    The configuration key to retrieve.

    .PARAMETER ConfigFile
    Optional path to a custom configuration file.

    .PARAMETER Default
    Default value to return if the key is not found.

    .PARAMETER Source
    The configuration source (File, Environment, Module).

    .EXAMPLE
    Get-StandardConfig -Key "LogLevel"

    .EXAMPLE
    Get-StandardConfig -Key "DatabaseConnectionString" -Source Environment -Default "Server=localhost"

    .EXAMPLE
    Get-StandardConfig -Key "ApiUrl" -ConfigFile "C:\Config\app.json"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Key,

        [Parameter(Mandatory = $false)]
        [string]$ConfigFile,

        [Parameter(Mandatory = $false)]
        [object]$Default,

        [Parameter(Mandatory = $false)]
        [ValidateSet('File', 'Environment', 'Module', 'Auto')]
        [string]$Source = 'Auto'
    )

    try {
        Write-DebugLog -Message "Getting configuration for key: $Key" -Source "Get-StandardConfig"

        switch ($Source) {
            'Module' {
                if ($Script:PSDefaultsConfig.ContainsKey($Key)) {
                    return $Script:PSDefaultsConfig[$Key]
                }
            }
            'Environment' {
                $EnvValue = [Environment]::GetEnvironmentVariable($Key)
                if ($null -ne $EnvValue) {
                    return $EnvValue
                }
            }
            'File' {
                if ($ConfigFile -and (Test-Path $ConfigFile)) {
                    $Config = Get-Content $ConfigFile | ConvertFrom-Json
                    $Value = Get-ObjectProperty -Object $Config -PropertyPath $Key
                    if ($null -ne $Value) {
                        return $Value
                    }
                }
            }
            'Auto' {
                # Try each source in order: Module -> Environment -> File
                
                # Module configuration
                if ($Script:PSDefaultsConfig.ContainsKey($Key)) {
                    return $Script:PSDefaultsConfig[$Key]
                }
                
                # Environment variable
                $EnvValue = [Environment]::GetEnvironmentVariable($Key)
                if ($null -ne $EnvValue) {
                    return $EnvValue
                }
                
                # Default config file
                $DefaultConfigFile = Join-Path -Path $Script:PSDefaultsConfig.LogPath -ChildPath "config.json"
                if (Test-Path $DefaultConfigFile) {
                    $Config = Get-Content $DefaultConfigFile | ConvertFrom-Json
                    $Value = Get-ObjectProperty -Object $Config -PropertyPath $Key
                    if ($null -ne $Value) {
                        return $Value
                    }
                }
                
                # Custom config file if specified
                if ($ConfigFile -and (Test-Path $ConfigFile)) {
                    $Config = Get-Content $ConfigFile | ConvertFrom-Json
                    $Value = Get-ObjectProperty -Object $Config -PropertyPath $Key
                    if ($null -ne $Value) {
                        return $Value
                    }
                }
            }
        }

        # Return default if no value found
        if ($null -ne $Default) {
            Write-DebugLog -Message "Configuration key '$Key' not found, returning default value" -Source "Get-StandardConfig"
            return $Default
        }

        Write-WarningLog -Message "Configuration key '$Key' not found and no default provided" -Source "Get-StandardConfig"
        return $null

    } catch {
        Write-ErrorLog -Message "Failed to get configuration for key '$Key': $($_.Exception.Message)" -Source "Get-StandardConfig"
        return $Default
    }
}

function Set-StandardConfig {
    <#
    .SYNOPSIS
    Sets configuration values in the standard configuration system.

    .DESCRIPTION
    Sets configuration values in the module configuration, environment variables, or JSON files.

    .PARAMETER Key
    The configuration key to set.

    .PARAMETER Value
    The value to set.

    .PARAMETER ConfigFile
    Optional path to a configuration file.

    .PARAMETER Target
    Where to store the configuration (Module, Environment, File).

    .PARAMETER CreateFile
    Whether to create the config file if it doesn't exist.

    .EXAMPLE
    Set-StandardConfig -Key "LogLevel" -Value "Debug"

    .EXAMPLE
    Set-StandardConfig -Key "ApiKey" -Value "secret123" -Target Environment

    .EXAMPLE
    Set-StandardConfig -Key "Database.ConnectionString" -Value "Server=prod" -Target File -CreateFile
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Key,

        [Parameter(Mandatory = $true)]
        [object]$Value,

        [Parameter(Mandatory = $false)]
        [string]$ConfigFile,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Module', 'Environment', 'File')]
        [string]$Target = 'Module',

        [Parameter(Mandatory = $false)]
        [switch]$CreateFile
    )

    try {
        Write-DebugLog -Message "Setting configuration for key: $Key" -Source "Set-StandardConfig"

        switch ($Target) {
            'Module' {
                $Script:PSDefaultsConfig[$Key] = $Value
                Write-InfoLog -Message "Module configuration updated: $Key" -Source "Set-StandardConfig"
            }
            'Environment' {
                [Environment]::SetEnvironmentVariable($Key, $Value.ToString(), 'Process')
                Write-InfoLog -Message "Environment variable set: $Key" -Source "Set-StandardConfig"
            }
            'File' {
                if (-not $ConfigFile) {
                    $ConfigFile = Join-Path -Path $Script:PSDefaultsConfig.LogPath -ChildPath "config.json"
                }

                $Config = @{}
                if (Test-Path $ConfigFile) {
                    $Config = Get-Content $ConfigFile | ConvertFrom-Json -AsHashtable
                } elseif (-not $CreateFile) {
                    throw "Configuration file does not exist: $ConfigFile"
                }

                # Handle nested keys (e.g., "Database.ConnectionString")
                Set-ObjectProperty -Object $Config -PropertyPath $Key -Value $Value

                # Ensure directory exists
                $ConfigDir = Split-Path -Path $ConfigFile -Parent
                if (-not (Test-Path $ConfigDir)) {
                    New-Item -Path $ConfigDir -ItemType Directory -Force | Out-Null
                }

                # Save configuration
                $Config | ConvertTo-Json -Depth 10 | Set-Content -Path $ConfigFile -Encoding UTF8
                Write-InfoLog -Message "Configuration file updated: $ConfigFile" -Source "Set-StandardConfig"
            }
        }

    } catch {
        Write-ErrorLog -Message "Failed to set configuration for key '$Key': $($_.Exception.Message)" -Source "Set-StandardConfig"
        throw
    }
}

function Import-StandardConfig {
    <#
    .SYNOPSIS
    Imports configuration from a JSON file into the module configuration.

    .DESCRIPTION
    Loads configuration values from a JSON file and merges them with the current module configuration.

    .PARAMETER ConfigFile
    Path to the configuration file to import.

    .PARAMETER Merge
    Whether to merge with existing configuration or replace it.

    .EXAMPLE
    Import-StandardConfig -ConfigFile "C:\Config\production.json"

    .EXAMPLE
    Import-StandardConfig -ConfigFile "settings.json" -Merge
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ConfigFile,

        [Parameter(Mandatory = $false)]
        [switch]$Merge
    )

    try {
        if (-not (Test-Path $ConfigFile)) {
            throw "Configuration file not found: $ConfigFile"
        }

        Write-InfoLog -Message "Importing configuration from: $ConfigFile" -Source "Import-StandardConfig"

        $ImportedConfig = Get-Content $ConfigFile | ConvertFrom-Json -AsHashtable

        if ($Merge) {
            foreach ($Key in $ImportedConfig.Keys) {
                $Script:PSDefaultsConfig[$Key] = $ImportedConfig[$Key]
            }
        } else {
            $Script:PSDefaultsConfig = $ImportedConfig
        }

        Write-InfoLog -Message "Configuration imported successfully" -Source "Import-StandardConfig"

    } catch {
        Write-ErrorLog -Message "Failed to import configuration: $($_.Exception.Message)" -Source "Import-StandardConfig"
        throw
    }
}

function Export-StandardConfig {
    <#
    .SYNOPSIS
    Exports the current module configuration to a JSON file.

    .DESCRIPTION
    Saves the current module configuration to a JSON file for backup or sharing.

    .PARAMETER ConfigFile
    Path where the configuration file will be saved.

    .PARAMETER IncludeSecrets
    Whether to include potentially sensitive configuration values.

    .EXAMPLE
    Export-StandardConfig -ConfigFile "C:\Backup\config.json"

    .EXAMPLE
    Export-StandardConfig -ConfigFile "public-config.json" -IncludeSecrets:$false
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ConfigFile,

        [Parameter(Mandatory = $false)]
        [bool]$IncludeSecrets = $true
    )

    try {
        Write-InfoLog -Message "Exporting configuration to: $ConfigFile" -Source "Export-StandardConfig"

        $ConfigToExport = $Script:PSDefaultsConfig.Clone()

        if (-not $IncludeSecrets) {
            # Remove potentially sensitive keys
            $SensitiveKeys = @('WebhookUrl', 'ApiKey', 'Password', 'Secret', 'Token', 'ConnectionString')
            foreach ($Key in $SensitiveKeys) {
                $ConfigToExport.Remove($Key)
            }
        }

        # Ensure directory exists
        $ConfigDir = Split-Path -Path $ConfigFile -Parent
        if (-not (Test-Path $ConfigDir)) {
            New-Item -Path $ConfigDir -ItemType Directory -Force | Out-Null
        }

        $ConfigToExport | ConvertTo-Json -Depth 10 | Set-Content -Path $ConfigFile -Encoding UTF8
        Write-InfoLog -Message "Configuration exported successfully" -Source "Export-StandardConfig"

    } catch {
        Write-ErrorLog -Message "Failed to export configuration: $($_.Exception.Message)" -Source "Export-StandardConfig"
        throw
    }
}