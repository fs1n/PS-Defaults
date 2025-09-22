# PS-Defaults.Networking PowerShell Module
# Network connectivity testing and endpoint monitoring

# Get the path of the module root
$ModuleRoot = $PSScriptRoot

# Import networking functions
$NetworkingFunctionPath = Join-Path -Path $ModuleRoot -ChildPath 'Public\Networking'
if (Test-Path $NetworkingFunctionPath) {
    Get-ChildItem -Path $NetworkingFunctionPath -Filter '*.ps1' -Recurse | ForEach-Object {
        . $_.FullName
    }
}