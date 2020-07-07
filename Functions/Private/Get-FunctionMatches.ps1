function Get-FunctionMatches {
    [CmdletBinding()]
    param (
        # Root function
        [Parameter()]
        [System.Object]
        $RootFunction,

        # Child functions
        [Parameter()]
        [System.Object[]]
        $ChildFunctions
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Starting function..."

    [string]$Path = $RootFunction.FullName
    [string[]]$Functions = $ChildFunctions.BaseName

    switch ($true) {
        {$null -eq $Path}           {
            Write-Warning -Message "$theFName Path to root script is EMPTY! Exiting."
            return
        }
        {$Functions.Count -lt 1}    {
            Write-Warning -Message "$theFName List of child functions is EMPTY! Exiting."
            return
        }
        Default {
            Write-Verbose -Message "$theFName Search for matches for $($Functions.Count) child functions in root script: $($Path)"
            continue
        }
    }

    try {
        Write-Verbose -Message "$theFName Trying to get content of file `"$Path`"..."
        [string[]]$scriptContent = Get-Content -Path $Path -ErrorAction Stop
    }
    catch [System.Management.Automation.ItemNotFoundException] {
        Write-Warning -Message "$theFName File `"$Path`" not found! Exiting."
        return
    }
    catch {
        throw
    }

    [string[]]$functionNamesUsed    = @()
    [string[]]$functionNamesUnUsed  = @()
    
    $Functions.ForEach({
        if ([regex]::Match($scriptContent, $_).Success) {
            $functionNamesUsed += $_
            Write-Verbose "Function $_ used in script `"$($RootFunction.BaseName)`"."
        } else {
            $functionNamesUnUsed += $_
            Write-Warning "Function $_ UNUSED in script `"$($RootFunction.BaseName)`"."
        }
    })

    if ($functionNamesUsed.Count -lt 1) {
        Write-Warning -Message "$theFName Seems like there are no any used functions in root script `"$($RootFunction.BaseName)`". Exiting."
        return
    }

    [System.Object[]]$functionsUsed = $ChildFunctions.Where({
        $_.BaseName -in $functionNamesUsed
    })
    Write-Verbose -Message "$theFName Found $($functionsUsed.Count) used functions in root script `"$($RootFunction.BaseName)`"."

    Write-Verbose -Message "$theFName End of function."
    return $functionsUsed
}
