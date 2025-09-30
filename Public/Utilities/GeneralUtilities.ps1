function ConvertTo-SecureString {
    <#
    .SYNOPSIS
    Converts a plain text string to a SecureString.

    .DESCRIPTION
    Safely converts plain text to SecureString for password handling.

    .PARAMETER PlainText
    The plain text string to convert.

    .EXAMPLE
    $SecurePassword = ConvertTo-SecureString -PlainText "MyPassword123"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PlainText
    )

    return ConvertTo-SecureString -String $PlainText -AsPlainText -Force
}

function ConvertFrom-SecureString {
    <#
    .SYNOPSIS
    Converts a SecureString back to plain text.

    .DESCRIPTION
    Converts a SecureString to plain text. Use with caution for security reasons.

    .PARAMETER SecureString
    The SecureString to convert.

    .EXAMPLE
    $PlainText = ConvertFrom-SecureString -SecureString $SecurePassword
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.Security.SecureString]$SecureString
    )

    try {
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
        return [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    } finally {
        if ($BSTR) {
            [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
        }
    }
}

function New-TemporaryDirectory {
    <#
    .SYNOPSIS
    Creates a new temporary directory.

    .DESCRIPTION
    Creates a temporary directory with a unique name and returns the path.

    .PARAMETER Prefix
    Optional prefix for the directory name.

    .EXAMPLE
    $TempDir = New-TemporaryDirectory -Prefix "MyApp"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Prefix = "PSDefaults"
    )

    try {
        $TempPath = [System.IO.Path]::GetTempPath()
        $TempDirName = "$Prefix-$(Get-Date -Format 'yyyyMMdd-HHmmss')-$([System.Guid]::NewGuid().ToString().Substring(0,8))"
        $TempDirPath = Join-Path -Path $TempPath -ChildPath $TempDirName
        
        New-Item -Path $TempDirPath -ItemType Directory -Force | Out-Null
        
        Write-DebugLog -Message "Created temporary directory: $TempDirPath" -Source "New-TemporaryDirectory"
        return $TempDirPath
        
    } catch {
        Write-ErrorLog -Message "Failed to create temporary directory: $($_.Exception.Message)" -Source "New-TemporaryDirectory"
        throw
    }
}

function Remove-TemporaryDirectory {
    <#
    .SYNOPSIS
    Safely removes a temporary directory and all its contents.

    .DESCRIPTION
    Removes a directory and all its contents with error handling.

    .PARAMETER Path
    The path to the directory to remove.

    .PARAMETER Force
    Whether to force removal of read-only files.

    .EXAMPLE
    Remove-TemporaryDirectory -Path $TempDir -Force
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [switch]$Force
    )

    try {
        if (Test-Path $Path) {
            Remove-Item -Path $Path -Recurse -Force:$Force -ErrorAction Stop
            Write-DebugLog -Message "Removed temporary directory: $Path" -Source "Remove-TemporaryDirectory"
        } else {
            Write-WarningLog -Message "Directory does not exist: $Path" -Source "Remove-TemporaryDirectory"
        }
    } catch {
        Write-ErrorLog -Message "Failed to remove directory $Path`: $($_.Exception.Message)" -Source "Remove-TemporaryDirectory"
        throw
    }
}

function Format-FileSize {
    <#
    .SYNOPSIS
    Formats a file size in bytes to a human-readable format.

    .DESCRIPTION
    Converts bytes to KB, MB, GB, TB with appropriate formatting.

    .PARAMETER Bytes
    The number of bytes to format.

    .PARAMETER DecimalPlaces
    Number of decimal places to show.

    .EXAMPLE
    Format-FileSize -Bytes 1024000000
    # Returns "976.56 MB"

    .EXAMPLE
    Format-FileSize -Bytes 1073741824 -DecimalPlaces 0
    # Returns "1 GB"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [long]$Bytes,

        [Parameter(Mandatory = $false)]
        [int]$DecimalPlaces = 2
    )

    $Units = @('B', 'KB', 'MB', 'GB', 'TB', 'PB')
    $UnitIndex = 0
    $Size = [double]$Bytes

    while ($Size -ge 1024 -and $UnitIndex -lt ($Units.Length - 1)) {
        $Size = $Size / 1024
        $UnitIndex++
    }

    return "$([math]::Round($Size, $DecimalPlaces)) $($Units[$UnitIndex])"
}

function Test-Administrator {
    <#
    .SYNOPSIS
    Tests if the current session is running with administrator privileges.

    .DESCRIPTION
    Checks if the current PowerShell session has administrator/elevated privileges.

    .EXAMPLE
    if (Test-Administrator) {
        Write-Host "Running as administrator"
    }
    #>
    [CmdletBinding()]
    param()

    try {
        if ($IsWindows -or $PSVersionTable.PSEdition -eq 'Desktop') {
            $CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
            $Principal = New-Object Security.Principal.WindowsPrincipal($CurrentUser)
            return $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        } else {
            # For non-Windows systems, check if running as root
            return (whoami) -eq 'root'
        }
    } catch {
        Write-WarningLog -Message "Could not determine administrator status: $($_.Exception.Message)" -Source "Test-Administrator"
        return $false
    }
}

function Get-RandomString {
    <#
    .SYNOPSIS
    Generates a random string of specified length.

    .DESCRIPTION
    Creates a random string using specified character sets.

    .PARAMETER Length
    The length of the random string to generate.

    .PARAMETER IncludeUppercase
    Whether to include uppercase letters.

    .PARAMETER IncludeLowercase
    Whether to include lowercase letters.

    .PARAMETER IncludeNumbers
    Whether to include numbers.

    .PARAMETER IncludeSpecialChars
    Whether to include special characters.

    .PARAMETER CustomCharSet
    Custom character set to use instead of the standard sets.

    .EXAMPLE
    Get-RandomString -Length 12
    # Returns something like "Kp3mN8xQ2vR1"

    .EXAMPLE
    Get-RandomString -Length 8 -IncludeNumbers:$false -IncludeSpecialChars:$false
    # Returns something like "KpmnxQvR"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [int]$Length = 16,

        [Parameter(Mandatory = $false)]
        [bool]$IncludeUppercase = $true,

        [Parameter(Mandatory = $false)]
        [bool]$IncludeLowercase = $true,

        [Parameter(Mandatory = $false)]
        [bool]$IncludeNumbers = $true,

        [Parameter(Mandatory = $false)]
        [bool]$IncludeSpecialChars = $false,

        [Parameter(Mandatory = $false)]
        [string]$CustomCharSet
    )

    try {
        if ($CustomCharSet) {
            $CharSet = $CustomCharSet
        } else {
            $CharSet = ""
            if ($IncludeUppercase) { $CharSet += "ABCDEFGHIJKLMNOPQRSTUVWXYZ" }
            if ($IncludeLowercase) { $CharSet += "abcdefghijklmnopqrstuvwxyz" }
            if ($IncludeNumbers) { $CharSet += "0123456789" }
            if ($IncludeSpecialChars) { $CharSet += "!@#$%^&*()-_=+[]{}|;:,.<>?" }
        }

        if ([string]::IsNullOrEmpty($CharSet)) {
            throw "No character set specified for random string generation"
        }

        $Random = New-Object System.Random
        $Result = ""
        
        for ($i = 0; $i -lt $Length; $i++) {
            $RandomIndex = $Random.Next(0, $CharSet.Length)
            $Result += $CharSet[$RandomIndex]
        }

        return $Result

    } catch {
        Write-ErrorLog -Message "Failed to generate random string: $($_.Exception.Message)" -Source "Get-RandomString"
        throw
    }
}

function Invoke-WithRetry {
    <#
    .SYNOPSIS
    Executes a script block with retry logic.

    .DESCRIPTION
    Provides configurable retry logic for operations that may fail temporarily.

    .PARAMETER ScriptBlock
    The script block to execute.

    .PARAMETER MaxAttempts
    Maximum number of attempts.

    .PARAMETER DelaySeconds
    Delay between attempts in seconds.

    .PARAMETER ExponentialBackoff
    Whether to use exponential backoff for delays.

    .PARAMETER Source
    Source identifier for logging.

    .EXAMPLE
    Invoke-WithRetry -ScriptBlock { Invoke-RestMethod -Uri "https://api.example.com/data" } -MaxAttempts 5

    .EXAMPLE
    Invoke-WithRetry -ScriptBlock { 
        Test-Connection -ComputerName "server.example.com" -Count 1
    } -MaxAttempts 3 -DelaySeconds 10 -ExponentialBackoff
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [scriptblock]$ScriptBlock,

        [Parameter(Mandatory = $false)]
        [int]$MaxAttempts = 3,

        [Parameter(Mandatory = $false)]
        [int]$DelaySeconds = 5,

        [Parameter(Mandatory = $false)]
        [switch]$ExponentialBackoff,

        [Parameter(Mandatory = $false)]
        [string]$Source = 'Invoke-WithRetry'
    )

    $Attempt = 0
    $LastException = $null

    while ($Attempt -lt $MaxAttempts) {
        $Attempt++
        try {
            Write-DebugLog -Message "Executing script block (attempt $Attempt of $MaxAttempts)" -Source $Source
            return & $ScriptBlock
        } catch {
            $LastException = $_
            Write-WarningLog -Message "Attempt $Attempt failed: $($_.Exception.Message)" -Source $Source

            if ($Attempt -lt $MaxAttempts) {
                $Delay = if ($ExponentialBackoff) { $DelaySeconds * [Math]::Pow(2, $Attempt - 1) } else { $DelaySeconds }
                Write-InfoLog -Message "Retrying in $Delay seconds..." -Source $Source
                Start-Sleep -Seconds $Delay
            }
        }
    }

    Write-ErrorLog -Message "All $MaxAttempts attempts failed. Last error: $($LastException.Exception.Message)" -Source $Source
    throw $LastException
}

function Get-TOTPCode {
    <#
    .SYNOPSIS
    Generates a Time-based One-Time Password (TOTP) code.

    .DESCRIPTION
    Generates a TOTP code using a Base32-encoded shared secret, compatible with RFC 6238.
    Uses SHA1 HMAC with a 30-second time window and produces 6-digit codes.

    .PARAMETER SharedSecret
    The Base32-encoded shared secret key (without spaces or padding).

    .PARAMETER TimeWindow
    The time window in seconds for TOTP generation. Default is 30 seconds.

    .PARAMETER CodeLength
    The length of the generated TOTP code. Default is 6 digits.

    .EXAMPLE
    Get-TOTPCode -SharedSecret "QQ4AXYR5YARC3ZKWRPGTN3WUCQ"
    # Returns a 6-digit TOTP code like "123456"

    .EXAMPLE
    Get-TOTPCode -SharedSecret "JBSWY3DPEHPK3PXP" -TimeWindow 60 -CodeLength 8
    # Returns an 8-digit TOTP code with 60-second window
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$SharedSecret,

        [Parameter(Mandatory = $false)]
        [int]$TimeWindow = 30,

        [Parameter(Mandatory = $false)]
        [int]$CodeLength = 6
    )

    try {
        # Base32 decode (RFC4648) - returns a byte[]
        function FromBase32String {
            param([string]$Base32)
            
            $map = @{
                'A'=0; 'B'=1; 'C'=2; 'D'=3; 'E'=4; 'F'=5; 'G'=6; 'H'=7;
                'I'=8; 'J'=9; 'K'=10; 'L'=11; 'M'=12; 'N'=13; 'O'=14; 'P'=15;
                'Q'=16; 'R'=17; 'S'=18; 'T'=19; 'U'=20; 'V'=21; 'W'=22; 'X'=23;
                'Y'=24; 'Z'=25; '2'=26; '3'=27; '4'=28; '5'=29; '6'=30; '7'=31
            }
            
            if ([string]::IsNullOrEmpty($Base32)) { 
                return ,([byte[]]@()) 
            }
            
            # Normalize: remove padding, spaces and any non-base32 characters
            $s = ($Base32.ToUpper() -replace '[^A-Z2-7]', '')
            if ($s.Length -eq 0) { 
                return ,([byte[]]@()) 
            }
            
            $buffer = 0
            $bitsLeft = 0
            $bytes = New-Object System.Collections.Generic.List[byte]
            
            foreach ($ch in $s.ToCharArray()) {
                $key = [string]$ch
                if (-not $map.ContainsKey($key)) {
                    continue
                }
                
                $val = $map[$key]
                $buffer = ($buffer -shl 5) -bor $val
                $bitsLeft += 5
                
                while ($bitsLeft -ge 8) {
                    $bitsLeft -= 8
                    $b = ($buffer -shr $bitsLeft) -band 0xFF
                    $bytes.Add([byte]$b)
                }
            }
            return $bytes.ToArray()
        }

        # Calculate time counter
        $unixTime = [int64](Get-Date -UFormat %s)
        $counter = [math]::Floor($unixTime / $TimeWindow)
        
        # Convert counter to 8-byte array (big-endian)
        $counterBytes = New-Object byte[] 8
        for ($i = 7; $i -ge 0; $i--) {
            $counterBytes[$i] = [byte]($counter -band 0xFF)
            $counter = $counter -shr 8
        }

        # Generate HMAC-SHA1
        $hmac = New-Object System.Security.Cryptography.HMACSHA1
        $hmac.Key = FromBase32String $SharedSecret
        $hash = $hmac.ComputeHash($counterBytes)

        # Dynamic truncation
        $offset = $hash[19] -band 0x0F
        $binary = (($hash[$offset] -band 0x7F) -shl 24) -bor
                  (($hash[$offset + 1] -band 0xFF) -shl 16) -bor
                  (($hash[$offset + 2] -band 0xFF) -shl 8) -bor
                  ($hash[$offset + 3] -band 0xFF)

        # Generate OTP
        $otp = $binary % [math]::Pow(10, $CodeLength)
        
        return $otp.ToString().PadLeft($CodeLength, '0')

    } catch {
        Write-ErrorLog -Message "Failed to generate TOTP code: $($_.Exception.Message)" -Source "Get-TOTPCode"
        throw
    }
}
