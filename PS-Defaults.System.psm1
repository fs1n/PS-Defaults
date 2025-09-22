# PS-Defaults.System PowerShell Module
# System information gathering and monitoring

# Get the path of the module root
$ModuleRoot = $PSScriptRoot

# Import system functions
$SystemFunctionPath = Join-Path -Path $ModuleRoot -ChildPath 'Public\System'
if (Test-Path $SystemFunctionPath) {
    Get-ChildItem -Path $SystemFunctionPath -Filter '*.ps1' -Recurse | ForEach-Object {
        . $_.FullName
    }
}