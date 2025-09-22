@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'PS-Defaults.System.psm1'

    # Version number of this module.
    ModuleVersion = '1.0.0'

    # Supported PSEditions
    CompatiblePSEditions = @('Desktop', 'Core')

    # ID used to uniquely identify this module
    GUID = '12345678-1234-1234-1234-123456789016'

    # Author of this module
    Author = 'Frederik S.'

    # Company or vendor of this module
    CompanyName = 'Unknown'

    # Copyright statement for this module
    Copyright = '(c) 2025 Frederik S. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'PS-Defaults System module - System information gathering, disk space monitoring, and system utilities.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        'Get-SystemInfo',
        'Get-DiskSpaceInfo'
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
            Tags = @('IT', 'Standard', 'System', 'Monitoring', 'Information')

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/fs1n/PS-Defaults/blob/main/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/fs1n/PS-Defaults'

            # ReleaseNotes of this module
            ReleaseNotes = 'System module with system information gathering and monitoring capabilities.'

        } # End of PSData hashtable

    } # End of PrivateData hashtable

}