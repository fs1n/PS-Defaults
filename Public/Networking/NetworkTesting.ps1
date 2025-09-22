function Test-NetworkConnectivity {
    <#
    .SYNOPSIS
    Tests network connectivity to specified hosts and ports.

    .DESCRIPTION
    Provides comprehensive network connectivity testing including ping, port connectivity, and DNS resolution.

    .PARAMETER ComputerName
    The computer name or IP address to test.

    .PARAMETER Port
    The port number to test (optional).

    .PARAMETER Timeout
    Timeout in milliseconds for the test.

    .PARAMETER TestDNS
    Whether to test DNS resolution.

    .PARAMETER TestPing
    Whether to test ping connectivity.

    .PARAMETER TestPort
    Whether to test port connectivity.

    .EXAMPLE
    Test-NetworkConnectivity -ComputerName "google.com" -Port 443

    .EXAMPLE
    Test-NetworkConnectivity -ComputerName "192.168.1.1" -TestPing -TestDNS
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ComputerName,

        [Parameter(Mandatory = $false)]
        [int]$Port,

        [Parameter(Mandatory = $false)]
        [int]$Timeout = 5000,

        [Parameter(Mandatory = $false)]
        [switch]$TestDNS,

        [Parameter(Mandatory = $false)]
        [switch]$TestPing,

        [Parameter(Mandatory = $false)]
        [switch]$TestPort
    )

    $Results = @{
        ComputerName = $ComputerName
        Port = $Port
        Timestamp = Get-Date
        DNS = $null
        Ping = $null
        PortConnectivity = $null
        Success = $false
    }

    try {
        Write-InfoLog -Message "Testing connectivity to $ComputerName" -Source "Test-NetworkConnectivity"

        # Test DNS Resolution
        if ($TestDNS -or (-not $TestPing -and -not $TestPort)) {
            try {
                $DnsResult = Resolve-DnsName -Name $ComputerName -ErrorAction Stop
                $Results.DNS = @{
                    Success = $true
                    IPAddresses = $DnsResult | Where-Object { $_.Type -eq 'A' } | Select-Object -ExpandProperty IPAddress
                    Error = $null
                }
                Write-DebugLog -Message "DNS resolution successful for $ComputerName" -Source "Test-NetworkConnectivity"
            } catch {
                $Results.DNS = @{
                    Success = $false
                    IPAddresses = @()
                    Error = $_.Exception.Message
                }
                Write-WarningLog -Message "DNS resolution failed for $ComputerName`: $($_.Exception.Message)" -Source "Test-NetworkConnectivity"
            }
        }

        # Test Ping
        if ($TestPing -or (-not $TestDNS -and -not $TestPort)) {
            try {
                $PingResult = Test-Connection -ComputerName $ComputerName -Count 1 -Quiet -ErrorAction Stop
                $Results.Ping = @{
                    Success = $PingResult
                    Error = if (-not $PingResult) { "Ping failed" } else { $null }
                }
                if ($PingResult) {
                    Write-DebugLog -Message "Ping successful to $ComputerName" -Source "Test-NetworkConnectivity"
                } else {
                    Write-WarningLog -Message "Ping failed to $ComputerName" -Source "Test-NetworkConnectivity"
                }
            } catch {
                $Results.Ping = @{
                    Success = $false
                    Error = $_.Exception.Message
                }
                Write-WarningLog -Message "Ping test failed for $ComputerName`: $($_.Exception.Message)" -Source "Test-NetworkConnectivity"
            }
        }

        # Test Port Connectivity
        if ($Port -and ($TestPort -or (-not $TestDNS -and -not $TestPing))) {
            try {
                $TcpClient = New-Object System.Net.Sockets.TcpClient
                $AsyncResult = $TcpClient.BeginConnect($ComputerName, $Port, $null, $null)
                $Success = $AsyncResult.AsyncWaitHandle.WaitOne($Timeout, $false)
                
                if ($Success) {
                    $TcpClient.EndConnect($AsyncResult)
                    $Results.PortConnectivity = @{
                        Success = $true
                        Error = $null
                    }
                    Write-DebugLog -Message "Port $Port is accessible on $ComputerName" -Source "Test-NetworkConnectivity"
                } else {
                    $Results.PortConnectivity = @{
                        Success = $false
                        Error = "Connection timeout"
                    }
                    Write-WarningLog -Message "Port $Port is not accessible on $ComputerName (timeout)" -Source "Test-NetworkConnectivity"
                }
                
                $TcpClient.Close()
            } catch {
                $Results.PortConnectivity = @{
                    Success = $false
                    Error = $_.Exception.Message
                }
                Write-WarningLog -Message "Port connectivity test failed for $ComputerName`:$Port - $($_.Exception.Message)" -Source "Test-NetworkConnectivity"
            }
        }

        # Determine overall success
        $Results.Success = $(
            ($null -eq $Results.DNS -or $Results.DNS.Success) -and
            ($null -eq $Results.Ping -or $Results.Ping.Success) -and
            ($null -eq $Results.PortConnectivity -or $Results.PortConnectivity.Success)
        )

        if ($Results.Success) {
            Write-InfoLog -Message "Network connectivity test passed for $ComputerName" -Source "Test-NetworkConnectivity"
        } else {
            Write-WarningLog -Message "Network connectivity test failed for $ComputerName" -Source "Test-NetworkConnectivity"
        }

        return $Results

    } catch {
        Write-ErrorLog -Message "Network connectivity test error for $ComputerName`: $($_.Exception.Message)" -Source "Test-NetworkConnectivity"
        $Results.Success = $false
        return $Results
    }
}

function Test-WebEndpoint {
    <#
    .SYNOPSIS
    Tests HTTP/HTTPS endpoints for availability and response.

    .DESCRIPTION
    Tests web endpoints with configurable timeout, expected status codes, and response validation.

    .PARAMETER Uri
    The URI to test.

    .PARAMETER Method
    HTTP method to use (GET, POST, etc.).

    .PARAMETER ExpectedStatusCode
    Expected HTTP status code.

    .PARAMETER Timeout
    Request timeout in seconds.

    .PARAMETER Headers
    Optional headers to include in the request.

    .PARAMETER Body
    Optional body content for POST requests.

    .EXAMPLE
    Test-WebEndpoint -Uri "https://api.example.com/health"

    .EXAMPLE
    Test-WebEndpoint -Uri "https://api.example.com/status" -ExpectedStatusCode 200 -Timeout 10
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Uri,

        [Parameter(Mandatory = $false)]
        [string]$Method = 'GET',

        [Parameter(Mandatory = $false)]
        [int]$ExpectedStatusCode = 200,

        [Parameter(Mandatory = $false)]
        [int]$Timeout = 30,

        [Parameter(Mandatory = $false)]
        [hashtable]$Headers = @{},

        [Parameter(Mandatory = $false)]
        [string]$Body
    )

    $Results = @{
        Uri = $Uri
        Method = $Method
        Timestamp = Get-Date
        Success = $false
        StatusCode = $null
        ResponseTime = $null
        ContentLength = $null
        Error = $null
    }

    try {
        Write-InfoLog -Message "Testing web endpoint: $Uri" -Source "Test-WebEndpoint"

        $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        
        $RequestParams = @{
            Uri = $Uri
            Method = $Method
            TimeoutSec = $Timeout
            Headers = $Headers
            ErrorAction = 'Stop'
        }

        if ($Body) {
            $RequestParams.Body = $Body
        }

        $Response = Invoke-WebRequest @RequestParams
        $Stopwatch.Stop()

        $Results.StatusCode = $Response.StatusCode
        $Results.ResponseTime = $Stopwatch.ElapsedMilliseconds
        $Results.ContentLength = $Response.Content.Length
        $Results.Success = ($Response.StatusCode -eq $ExpectedStatusCode)

        if ($Results.Success) {
            Write-InfoLog -Message "Web endpoint test passed for $Uri (Status: $($Response.StatusCode), Time: $($Results.ResponseTime)ms)" -Source "Test-WebEndpoint"
        } else {
            Write-WarningLog -Message "Web endpoint test failed for $Uri - Expected status $ExpectedStatusCode, got $($Response.StatusCode)" -Source "Test-WebEndpoint"
        }

    } catch {
        $Stopwatch.Stop()
        $Results.Error = $_.Exception.Message
        $Results.ResponseTime = $Stopwatch.ElapsedMilliseconds
        
        # Try to extract status code from web exception
        if ($_.Exception -is [System.Net.WebException]) {
            $HttpResponse = $_.Exception.Response
            if ($HttpResponse) {
                $Results.StatusCode = [int]$HttpResponse.StatusCode
            }
        }

        Write-ErrorLog -Message "Web endpoint test error for $Uri`: $($_.Exception.Message)" -Source "Test-WebEndpoint"
    }

    return $Results
}