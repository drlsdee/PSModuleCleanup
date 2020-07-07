function Select-ScriptNames {
    [CmdletBinding()]
    param (
        # Path to script folder
        [Parameter()]
        [string]
        $Path,

        # Array of valid script extensions, e.g. '.ps1'
        [Parameter()]
        [string[]]
        $extensionsValid = @(
            '.ps1'
            '.psm1'
        )
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Starting function..."

    try {
        Write-Verbose -Message "$theFName Resolving path `"$Path`"..."
        [string]$Path = (Resolve-Path -Path $Path -ErrorAction Stop).Path
    }
    catch {
        Write-Warning -Message "$theFName Path `"$Path`" does not exists!"
        return
    }

    [System.IO.FileInfo[]]$filesAll = Get-ChildItem -Path $Path -File
    [System.IO.FileInfo[]]$functionsAll = $filesAll.Where({$_.Extension -in $extensionsValid})
    if ($functionsAll.Count -lt 1) {
        Write-Warning -Message "$theFName Files with extensions like `"$extensionsValid`" are not fonud in folder `"$Path`"! Exiting."
        return $null
    }

    [System.Object[]]$namesAll = $functionsAll | Select-Object -Property BaseName, FullName
    $namesAll.ForEach({
        Write-Verbose -Message "$theFName Found function `"$($_.BaseName)`" in path `"$($_.FullName)`"."
    })

    Write-Verbose -Message "$theFName End of function."
    return $namesAll
}
