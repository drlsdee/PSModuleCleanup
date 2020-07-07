function Find-UnusedFunctions {
    [CmdletBinding()]
    param (
        # Path to PS module's root folder
        [Parameter()]
        [string]
        $Path,

        # What to return: used or unused functions
        [Parameter()]
        [ValidateSet('Used', 'Unused')]
        [string]
        $UsedOrUnused = 'Used'
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Starting function..."

    try {
        Write-Verbose -Message "$theFName Resolving path `"$Path`"..."
        [string]$Path = Resolve-Path -Path $Path -ErrorAction Stop
    }
    catch [System.Management.Automation.ItemNotFoundException] {
        Write-Warning -Message "$theFName Path `"$Path`" does not exists! Exiting."
        return
    }
    catch {
        throw
    }
    
    if (Test-Path -Path $Path -PathType Leaf) {
        Write-Warning -Message "$theFName Given path `"$Path`" is a file path. Trying to get directory path."
        $Path = [System.IO.Path]::GetDirectoryName($Path)
    }

    [System.Object[]]$functionsPublic       = Get-ScriptNames -Path $Path -PrivateOrPublic Public
    [System.Object[]]$functionsPrivateAll   = Get-ScriptNames -Path $Path -PrivateOrPublic Private
    [System.Object[]]$functionsPrivateUsed  = @()

    $functionsPublicCount = 0

    $functionsPublic.ForEach({
        [System.Object[]]$funcPriv = Get-FunctionMatches -RootFunction $_ -ChildFunctions $functionsPrivateAll
        if ($funcPriv.Count) {
            $functionsPrivateUsed += $funcPriv
            $functionsPublicCount++
        }
    })
    Write-Verbose -Message "$theFName Found $($functionsPrivateUsed.Count) private functions used in $($functionsPublicCount) exported functions."

    [System.Object[]]$functionsPrivateInternal = @()
    [System.Object[]]$functionsPrivateCount = @()

    $functionsPrivateUsed.ForEach({
        $functionCurrent = $_
        [System.Object[]]$funcPrivFiltered = $functionsPrivateAll.Where({$_ -ne $functionCurrent})
        [System.Object[]]$funcPrivInt = Get-FunctionMatches -RootFunction $_ -ChildFunctions $funcPrivFiltered
        if ($funcPrivInt.Count) {
            $functionsPrivateInternal += $funcPrivInt
            $functionsPrivateCount += $functionCurrent
        }
    })
    if ($functionsPrivateInternal) {
        Write-Verbose -Message "$theFName Found also $($functionsPrivateInternal.Count) private functions used in $($functionsPrivateCount.Count) PRIVATE functions."
        $functionsPrivateCount.ForEach({
            Write-Verbose -Message "$theFName Private function `"$($_.BaseName)`"; path: $($_.FullName)"
        })
        $functionsPrivateInternal.ForEach({
            Write-Verbose -Message "$theFName INTERNAL function `"$($_.BaseName)`"; path: $($_.FullName)"
        })
        $functionsPrivateUsed += $functionsPrivateInternal
    }

    [System.Object[]]$functionsPrivateUnused = $functionsPrivateAll.Where({$_ -notin $functionsPrivateUsed})

    Write-Verbose -Message "$theFName End of function. Returning result..."

    switch ($UsedOrUnused) {
        'Used'      {
            Write-Verbose -Message "$theFName Found $($functionsPrivateUsed.Count) used functions total:"
            return $functionsPrivateUsed
        }
        'Unused'    {
            Write-Verbose -Message "$theFName Found $($functionsPrivateUnused.Count) UNUSED functions total:"
            return $functionsPrivateUnused
        }
    }
}