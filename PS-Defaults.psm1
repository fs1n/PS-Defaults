# PS-Defaults PowerShell Module Framework
# Modular architecture with pluggable functionality

# This main module provides backward compatibility by loading PS-Defaults.Default
# Users can load specific modules directly for targeted functionality:
# - PS-Defaults.Default (core functions)
# - PS-Defaults.AdvancedLogging (enhanced logging)
# - PS-Defaults.Networking (network utilities)
# - PS-Defaults.System (system monitoring)

Write-Host "PS-Defaults Framework loaded. Available modules:" -ForegroundColor Green
Write-Host "  - PS-Defaults.Default (loaded automatically for compatibility)" -ForegroundColor Cyan
Write-Host "  - PS-Defaults.AdvancedLogging (Import-Module PS-Defaults.AdvancedLogging)" -ForegroundColor Cyan
Write-Host "  - PS-Defaults.Networking (Import-Module PS-Defaults.Networking)" -ForegroundColor Cyan
Write-Host "  - PS-Defaults.System (Import-Module PS-Defaults.System)" -ForegroundColor Cyan

# The Default module is automatically loaded via NestedModules in the manifest
# This ensures backward compatibility for existing scripts