<#

.SYNOPSIS
    This script checks and performs script updates.

.DESCRIPTION
    This script checks for updates either from Git or a specified URL (UpdateUrl -> Static webserver Content).

.PARAMETER UpdateUrl
    The URL to check for updates from.

.EXAMPLE
    .\SelfUpdate.ps1 -UpdateUrl "https://git.example.com/myscript/script.ps1" -> Or release

#>