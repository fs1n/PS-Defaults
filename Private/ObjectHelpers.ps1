function Get-ObjectProperty {
    <#
    .SYNOPSIS
    Gets a property value from an object using a dot-notation path.

    .DESCRIPTION
    Safely retrieves a property value from an object using dot notation (e.g., "Database.ConnectionString").

    .PARAMETER Object
    The object to get the property from.

    .PARAMETER PropertyPath
    The property path using dot notation.

    .EXAMPLE
    Get-ObjectProperty -Object $Config -PropertyPath "Database.ConnectionString"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$Object,

        [Parameter(Mandatory = $true)]
        [string]$PropertyPath
    )

    $Properties = $PropertyPath -split '\.'
    $Current = $Object

    foreach ($Property in $Properties) {
        if ($null -eq $Current) {
            return $null
        }
        
        if ($Current -is [hashtable]) {
            $Current = $Current[$Property]
        } elseif ($Current.PSObject.Properties[$Property]) {
            $Current = $Current.$Property
        } else {
            return $null
        }
    }

    return $Current
}

function Set-ObjectProperty {
    <#
    .SYNOPSIS
    Sets a property value on an object using a dot-notation path.

    .DESCRIPTION
    Safely sets a property value on an object using dot notation, creating nested objects as needed.

    .PARAMETER Object
    The object to set the property on.

    .PARAMETER PropertyPath
    The property path using dot notation.

    .PARAMETER Value
    The value to set.

    .EXAMPLE
    Set-ObjectProperty -Object $Config -PropertyPath "Database.ConnectionString" -Value "Server=localhost"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$Object,

        [Parameter(Mandatory = $true)]
        [string]$PropertyPath,

        [Parameter(Mandatory = $true)]
        [object]$Value
    )

    $Properties = $PropertyPath -split '\.'
    $Current = $Object

    for ($i = 0; $i -lt $Properties.Length - 1; $i++) {
        $Property = $Properties[$i]
        
        if ($Current -is [hashtable]) {
            if (-not $Current.ContainsKey($Property)) {
                $Current[$Property] = @{}
            }
            $Current = $Current[$Property]
        } else {
            if (-not $Current.PSObject.Properties[$Property]) {
                $Current | Add-Member -NotePropertyName $Property -NotePropertyValue @{}
            }
            $Current = $Current.$Property
        }
    }

    $LastProperty = $Properties[-1]
    if ($Current -is [hashtable]) {
        $Current[$LastProperty] = $Value
    } else {
        $Current | Add-Member -NotePropertyName $LastProperty -NotePropertyValue $Value -Force
    }
}