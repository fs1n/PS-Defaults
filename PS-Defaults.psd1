@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'PS-Defaults.psm1'

    # Version number of this module.
    ModuleVersion = '1.0.0'

    # Supported PSEditions
    CompatiblePSEditions = @('Desktop', 'Core')

    # ID used to uniquely identify this module
    GUID = '12345678-1234-1234-1234-123456789012'

    # Author of this module
    Author = 'Frederik S.'

    # Company or vendor of this module
    CompanyName = 'Unknown'

    # Copyright statement for this module
    Copyright = '(c) 2025 Frederik S. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'A modular PowerShell framework that standardizes repeating script functions for IT environments. Includes PS-Defaults.Default (core), PS-Defaults.AdvancedLogging, PS-Defaults.Networking, and PS-Defaults.System modules.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Name of the Windows PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the Windows PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # CLRVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    # RequiredModules = @()

    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @()

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    NestedModules = @('PS-Defaults.Default')

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

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    # FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('IT', 'Standard', 'Logging', 'Error-Handling', 'Webhook', 'Utilities', 'Modular', 'Framework')

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/fs1n/PS-Defaults/blob/main/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/fs1n/PS-Defaults'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            ReleaseNotes = 'Modular release of PS-Defaults with pluggable module architecture. Default compatibility maintained with PS-Defaults.Default nested module.'

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''

}