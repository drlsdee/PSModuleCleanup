function Get-ScriptNames {
    [CmdletBinding()]
    param (
        # Path to repo
        [Parameter()]
        [string]
        $Path,

        # Functions folder name
        [Parameter()]
        [string]
        $FunctionsFolder = 'Functions',

        # Private or public
        [Parameter()]
        [ValidateSet('Private', 'Public')]
        [string]
        $PrivateOrPublic
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Starting function..."

    [string]$Path = (Resolve-Path -Path $Path).Path

    [string]$pathToFunctionsAll = Join-Path -Path $Path -ChildPath $FunctionsFolder
    if ($PrivateOrPublic) {
        [string]$pathToFunctions    = Join-Path -Path $pathToFunctionsAll -ChildPath $PrivateOrPublic
        Write-Verbose -Message "$theFName Working with $PrivateOrPublic functions in folder `"$pathToFunctions`"..."
    }
    else {
        [string]$pathToFunctions = $pathToFunctionsAll
        Write-Warning -Message "$theFName Working with ALL functions in folder `"$pathToFunctions`"..."
    }

    [System.Object[]]$outObject = Select-ScriptNames -Path $pathToFunctions

    Write-Verbose -Message "$theFName End of function."
    return $outObject
}
