function Get-SystemInfo {
    <#
    .SYNOPSIS
    Retrieves comprehensive system information.

    .DESCRIPTION
    Gathers system information including OS details, hardware specs, disk space, and performance metrics.

    .PARAMETER IncludePerformance
    Whether to include performance counters (CPU, memory usage).

    .PARAMETER IncludeDiskSpace
    Whether to include disk space information.

    .PARAMETER IncludeNetworkInfo
    Whether to include network adapter information.

    .PARAMETER IncludeInstalledSoftware
    Whether to include a list of installed software.

    .EXAMPLE
    Get-SystemInfo

    .EXAMPLE
    Get-SystemInfo -IncludePerformance -IncludeDiskSpace
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$IncludePerformance,

        [Parameter(Mandatory = $false)]
        [switch]$IncludeDiskSpace,

        [Parameter(Mandatory = $false)]
        [switch]$IncludeNetworkInfo,

        [Parameter(Mandatory = $false)]
        [switch]$IncludeInstalledSoftware
    )

    try {
        Write-InfoLog -Message "Gathering system information" -Source "Get-SystemInfo"

        $SystemInfo = @{
            Timestamp = Get-Date
            ComputerName = $env:COMPUTERNAME
            UserName = $env:USERNAME
            Domain = $env:USERDOMAIN
            PowerShellVersion = $PSVersionTable.PSVersion.ToString()
            OperatingSystem = @{}
            Hardware = @{}
        }

        # Operating System Information
        try {
            $OS = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue
            if ($OS) {
                $SystemInfo.OperatingSystem = @{
                    Name = $OS.Caption
                    Version = $OS.Version
                    BuildNumber = $OS.BuildNumber
                    Architecture = $OS.OSArchitecture
                    InstallDate = $OS.InstallDate
                    LastBootUpTime = $OS.LastBootUpTime
                    TotalMemoryGB = [math]::Round($OS.TotalVisibleMemorySize / 1MB, 2)
                    FreeMemoryGB = [math]::Round($OS.FreePhysicalMemory / 1MB, 2)
                }
            } else {
                # Fallback for non-Windows systems
                $SystemInfo.OperatingSystem = @{
                    Name = $PSVersionTable.Platform
                    Version = "Unknown"
                    Architecture = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture
                }
            }
        } catch {
            Write-WarningLog -Message "Could not retrieve OS information: $($_.Exception.Message)" -Source "Get-SystemInfo"
        }

        # Hardware Information
        try {
            $Processor = Get-CimInstance -ClassName Win32_Processor -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($Processor) {
                $SystemInfo.Hardware = @{
                    ProcessorName = $Processor.Name
                    ProcessorCores = $Processor.NumberOfCores
                    ProcessorLogicalProcessors = $Processor.NumberOfLogicalProcessors
                    ProcessorSpeedMHz = $Processor.MaxClockSpeed
                }
            }
        } catch {
            Write-WarningLog -Message "Could not retrieve hardware information: $($_.Exception.Message)" -Source "Get-SystemInfo"
        }

        # Performance Information
        if ($IncludePerformance) {
            try {
                $SystemInfo.Performance = @{}
                
                # CPU Usage
                if ($IsWindows -or $PSVersionTable.PSEdition -eq 'Desktop') {
                    $CPU = Get-Counter -Counter "\Processor(_Total)\% Processor Time" -SampleInterval 1 -MaxSamples 2 -ErrorAction SilentlyContinue
                    if ($CPU) {
                        $SystemInfo.Performance.CPUUsagePercent = [math]::Round($CPU.CounterSamples[-1].CookedValue, 2)
                    }
                }

                # Memory Usage (already calculated above)
                if ($SystemInfo.OperatingSystem.TotalMemoryGB -and $SystemInfo.OperatingSystem.FreeMemoryGB) {
                    $MemoryUsedGB = $SystemInfo.OperatingSystem.TotalMemoryGB - $SystemInfo.OperatingSystem.FreeMemoryGB
                    $SystemInfo.Performance.MemoryUsagePercent = [math]::Round(($MemoryUsedGB / $SystemInfo.OperatingSystem.TotalMemoryGB) * 100, 2)
                }

            } catch {
                Write-WarningLog -Message "Could not retrieve performance information: $($_.Exception.Message)" -Source "Get-SystemInfo"
            }
        }

        # Disk Space Information
        if ($IncludeDiskSpace) {
            try {
                $Disks = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" -ErrorAction SilentlyContinue
                if ($Disks) {
                    $SystemInfo.DiskSpace = @()
                    foreach ($Disk in $Disks) {
                        $SystemInfo.DiskSpace += @{
                            Drive = $Disk.DeviceID
                            TotalSizeGB = [math]::Round($Disk.Size / 1GB, 2)
                            FreeSizeGB = [math]::Round($Disk.FreeSpace / 1GB, 2)
                            UsedSizeGB = [math]::Round(($Disk.Size - $Disk.FreeSpace) / 1GB, 2)
                            FreeSpacePercent = [math]::Round(($Disk.FreeSpace / $Disk.Size) * 100, 2)
                        }
                    }
                }
            } catch {
                Write-WarningLog -Message "Could not retrieve disk space information: $($_.Exception.Message)" -Source "Get-SystemInfo"
            }
        }

        # Network Information
        if ($IncludeNetworkInfo) {
            try {
                $NetworkAdapters = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -Filter "IPEnabled=True" -ErrorAction SilentlyContinue
                if ($NetworkAdapters) {
                    $SystemInfo.NetworkAdapters = @()
                    foreach ($Adapter in $NetworkAdapters) {
                        $SystemInfo.NetworkAdapters += @{
                            Description = $Adapter.Description
                            IPAddresses = $Adapter.IPAddress
                            SubnetMasks = $Adapter.IPSubnet
                            DefaultGateways = $Adapter.DefaultIPGateway
                            DNSServers = $Adapter.DNSServerSearchOrder
                            DHCPEnabled = $Adapter.DHCPEnabled
                        }
                    }
                }
            } catch {
                Write-WarningLog -Message "Could not retrieve network information: $($_.Exception.Message)" -Source "Get-SystemInfo"
            }
        }

        # Installed Software (Windows only, limited list)
        if ($IncludeInstalledSoftware) {
            try {
                if ($IsWindows -or $PSVersionTable.PSEdition -eq 'Desktop') {
                    $InstalledSoftware = Get-CimInstance -ClassName Win32_Product -ErrorAction SilentlyContinue | 
                        Select-Object Name, Version, InstallDate | 
                        Sort-Object Name |
                        Select-Object -First 50  # Limit to first 50 to avoid performance issues
                    
                    if ($InstalledSoftware) {
                        $SystemInfo.InstalledSoftware = $InstalledSoftware
                    }
                }
            } catch {
                Write-WarningLog -Message "Could not retrieve installed software information: $($_.Exception.Message)" -Source "Get-SystemInfo"
            }
        }

        Write-InfoLog -Message "System information gathered successfully" -Source "Get-SystemInfo"
        return $SystemInfo

    } catch {
        Write-ErrorLog -Message "Failed to gather system information: $($_.Exception.Message)" -Source "Get-SystemInfo"
        throw
    }
}

function Get-DiskSpaceInfo {
    <#
    .SYNOPSIS
    Gets detailed disk space information for all drives.

    .DESCRIPTION
    Provides detailed disk space information including usage alerts for low disk space.

    .PARAMETER WarningThresholdPercent
    Percentage threshold for disk space warnings.

    .PARAMETER CriticalThresholdPercent
    Percentage threshold for critical disk space alerts.

    .EXAMPLE
    Get-DiskSpaceInfo

    .EXAMPLE
    Get-DiskSpaceInfo -WarningThresholdPercent 20 -CriticalThresholdPercent 10
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [int]$WarningThresholdPercent = 15,

        [Parameter(Mandatory = $false)]
        [int]$CriticalThresholdPercent = 5
    )

    try {
        Write-InfoLog -Message "Getting disk space information" -Source "Get-DiskSpaceInfo"

        $DiskInfo = @{
            Timestamp = Get-Date
            Drives = @()
            Alerts = @()
        }

        $Disks = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" -ErrorAction SilentlyContinue

        if (-not $Disks) {
            # Fallback for non-Windows systems
            if (Get-Command Get-PSDrive -ErrorAction SilentlyContinue) {
                $PSDrives = Get-PSDrive -PSProvider FileSystem
                foreach ($Drive in $PSDrives) {
                    try {
                        $Used = $Drive.Used
                        $Free = $Drive.Free
                        $Total = $Used + $Free
                        if (-not $Total -or $Total -eq 0) {
                            Write-WarningLog -Message "Skipping drive $($Drive.Name) due to zero total size (possible offline or special mount)." -Source "Get-DiskSpaceInfo"
                            continue
                        }
                        $FreePercent = ($Free / $Total) * 100

                        $DriveInfo = @{
                            Drive = $Drive.Name + ":"
                            TotalSizeGB = [math]::Round($Total / 1GB, 2)
                            FreeSizeGB = [math]::Round($Free / 1GB, 2)
                            UsedSizeGB = [math]::Round($Used / 1GB, 2)
                            FreeSpacePercent = [math]::Round($FreePercent, 2)
                        }

                        $DiskInfo.Drives += $DriveInfo

                        # Check for alerts
                        if ($FreePercent -le $CriticalThresholdPercent) {
                            $DiskInfo.Alerts += @{
                                Level = 'Critical'
                                Drive = $DriveInfo.Drive
                                Message = "Critical: Only $([math]::Round($FreePercent, 1))% free space remaining"
                            }
                        } elseif ($FreePercent -le $WarningThresholdPercent) {
                            $DiskInfo.Alerts += @{
                                Level = 'Warning'
                                Drive = $DriveInfo.Drive
                                Message = "Warning: Only $([math]::Round($FreePercent, 1))% free space remaining"
                            }
                        }
                    } catch {
                        Write-WarningLog -Message "Could not get disk info for drive $($Drive.Name): $($_.Exception.Message)" -Source "Get-DiskSpaceInfo"
                    }
                }
            }
        } else {
            foreach ($Disk in $Disks) {
                # Guard against null or zero size values to prevent division by zero
                $diskSize = $Disk.Size
                $diskFree = $Disk.FreeSpace
                if (-not $diskSize -or $diskSize -eq 0) {
                    Write-WarningLog -Message "Skipping drive $($Disk.DeviceID) due to reported size 0 (cannot calculate free space percent)." -Source "Get-DiskSpaceInfo"
                    continue
                }
                $FreePercent = ($diskFree / $diskSize) * 100

                $DriveInfo = @{
                    Drive = $Disk.DeviceID
                    TotalSizeGB = [math]::Round($Disk.Size / 1GB, 2)
                    FreeSizeGB = [math]::Round($Disk.FreeSpace / 1GB, 2)
                    UsedSizeGB = [math]::Round(($Disk.Size - $Disk.FreeSpace) / 1GB, 2)
                    FreeSpacePercent = [math]::Round($FreePercent, 2)
                    VolumeLabel = $Disk.VolumeName
                    FileSystem = $Disk.FileSystem
                }

                $DiskInfo.Drives += $DriveInfo

                # Check for alerts
                if ($FreePercent -le $CriticalThresholdPercent) {
                    $DiskInfo.Alerts += @{
                        Level = 'Critical'
                        Drive = $DriveInfo.Drive
                        Message = "Critical: Only $([math]::Round($FreePercent, 1))% free space remaining on $($DriveInfo.Drive)"
                    }
                    Write-ErrorLog -Message "Critical disk space on $($DriveInfo.Drive): $([math]::Round($FreePercent, 1))% free" -Source "Get-DiskSpaceInfo"
                } elseif ($FreePercent -le $WarningThresholdPercent) {
                    $DiskInfo.Alerts += @{
                        Level = 'Warning'
                        Drive = $DriveInfo.Drive
                        Message = "Warning: Only $([math]::Round($FreePercent, 1))% free space remaining on $($DriveInfo.Drive)"
                    }
                    Write-WarningLog -Message "Low disk space on $($DriveInfo.Drive): $([math]::Round($FreePercent, 1))% free" -Source "Get-DiskSpaceInfo"
                }
            }
        }

        Write-InfoLog -Message "Disk space information gathered for $($DiskInfo.Drives.Count) drives" -Source "Get-DiskSpaceInfo"
        return $DiskInfo

    } catch {
        Write-ErrorLog -Message "Failed to get disk space information: $($_.Exception.Message)" -Source "Get-DiskSpaceInfo"
        throw
    }
}