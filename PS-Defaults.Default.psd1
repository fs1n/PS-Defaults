@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'PS-Defaults.Default.psm1'

    # Version number of this module.
    ModuleVersion = '1.0.0'

    # Supported PSEditions
    CompatiblePSEditions = @('Desktop', 'Core')

    # ID used to uniquely identify this module
    GUID = '12345678-1234-1234-1234-123456789013'

    # Author of this module
    Author = 'Frederik S.'

    # Company or vendor of this module
    CompanyName = 'Unknown'

    # Copyright statement for this module
    Copyright = '(c) 2025 Frederik S. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'PS-Defaults Default module - Core functionality including basic logging, configuration management, error handling, and essential utilities.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        'Write-StandardLog',
        'Get-StandardConfig',
        'Set-StandardConfig',
        'Initialize-StandardLogging',
        'Write-DebugLog',
        'Write-InfoLog',
        'Write-WarningLog',
        'Write-ErrorLog',
        'Send-ErrorWebhook',
        'Invoke-SafeCommand',
        'New-StandardException',
        'Send-NotificationWebhook',
        'Import-StandardConfig',
        'Export-StandardConfig',
        'ConvertTo-SecureString',
        'ConvertFrom-SecureString',
        'New-TemporaryDirectory',
        'Remove-TemporaryDirectory',
        'Format-FileSize',
        'Test-Administrator',
        'Get-RandomString',
        'Invoke-WithRetry'
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('IT', 'Standard', 'Logging', 'Error-Handling', 'Webhook', 'Utilities', 'Default', 'Core')

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/fs1n/PS-Defaults/blob/main/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/fs1n/PS-Defaults'

            # ReleaseNotes of this module
            ReleaseNotes = 'Default module of PS-Defaults with core functionality.'

        } # End of PSData hashtable

    } # End of PrivateData hashtable

}