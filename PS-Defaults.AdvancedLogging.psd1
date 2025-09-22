@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'PS-Defaults.AdvancedLogging.psm1'

    # Version number of this module.
    ModuleVersion = '1.0.0'

    # Supported PSEditions
    CompatiblePSEditions = @('Desktop', 'Core')

    # ID used to uniquely identify this module
    GUID = '12345678-1234-1234-1234-123456789014'

    # Author of this module
    Author = 'Frederik S.'

    # Company or vendor of this module
    CompanyName = 'Unknown'

    # Copyright statement for this module
    Copyright = '(c) 2025 Frederik S. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'PS-Defaults Advanced Logging module - Enhanced logging features with detailed formatting, log analysis, and advanced log management capabilities.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Modules that must be imported into the global environment prior to importing this module
    # RequiredModules = @('PS-Defaults.Default')

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        'Write-DetailedLog',
        'Get-LogAnalysis',
        'Export-LogReport',
        'Set-AdvancedLogFormat',
        'Start-LogSession',
        'Stop-LogSession',
        'Get-LogMetrics',
        'Write-StructuredLog',
        'Enable-LogForwarding',
        'Disable-LogForwarding'
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
            Tags = @('IT', 'Standard', 'Logging', 'Advanced', 'Analytics', 'Monitoring')

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/fs1n/PS-Defaults/blob/main/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/fs1n/PS-Defaults'

            # ReleaseNotes of this module
            ReleaseNotes = 'Advanced logging module with enhanced features for detailed log analysis and management.'

        } # End of PSData hashtable

    } # End of PrivateData hashtable

}