param (
    [Parameter(Position = 0, Mandatory=$true)]
    [string]$Version,

    [Parameter(Position = 1, Mandatory=$true)]
    [string]$Arch,

    [Parameter(Position = 2, Mandatory=$true)]
    [string]$Ts,

    [Parameter(Position = 3, Mandatory=$true)]
    [string]$Extension
)

Function Get-IniData($path)
{
    $data = @{}
    switch -regex -file $path
    {
        # Parse sections
        "^\[(.+)\]"
        {
            $section = $matches[1]
            $data[$section] = @{}
            $comments = 0
        }
        # Parse comments
        "^(;.*)$"
        {
            $value = $matches[1]
            $comments = $comments + 1
            $name = "Comment" + $comments
            $data[$section][$name] = $value
        }
        # Parse key values
        "(.+?)\s*=(.*)"
        {
            $name, $value = $matches[1..2]
            $data[$section][$name] = $value -replace '^"|"$', ''
        }
    }
    return $data
}

Function Get-Versions {
    param ([string]$InputFile)
    $jsonContent = Get-Content -Path $InputFile -Raw
    return ConvertFrom-Json -InputObject $jsonContent
}

Function Add-VSVersion {
    param (
        [PSCustomObject]$versions,
        [string]$OutputFile
    )
    Add-Content -Value "vs=$($versions.$Version)" -Path $OutputFile
}

Function Add-Config {
    param (
        [hashtable]$Ini,
        [string]$Extension,
        [string]$OutputFile
    )
    Add-Content -Value "config=$($ini[$Extension]['config'])" -Path $outputFile
}

Function Add-Libs {
    param (
        [hashtable]$Ini,
        [string]$Extension,
        [string]$OutputFile
    )
    $libs = if ($ini[$Extension].ContainsKey("libs")) { $ini[$Extension]["libs"] } else { "''" }
    Add-Content -Value "libs=$libs" -Path $outputFile
}

Function Add-PECLLibs {
    param (
        [hashtable]$Ini,
        [string]$Extension,
        [string]$OutputFile
    )
    if ($Ini[$Extension].ContainsKey("pecl_libs")) {
        $Ini[$Extension]["pecl_libs"] -split "`n" | Set-Content -Path $OutputFile
    }
}

Function Add-Extensions {
    param (
        [hashtable]$Ini,
        [string]$Extension,
        [string]$OutputFile
    )
    if ($Ini[$Extension].ContainsKey("exts")) {
        $lines = @()
        $exts = $Ini[$Extension]["exts"] -split ","
        foreach ($ext in $exts) {
            if ($Ini.ContainsKey($ext)) {
                $lines += "$ext`t$($Ini[$ext]['config'])`n"
            } else {
                throw "Unsupported dependency extension: $Extension"
            }
        }
        $lines | Set-Content -Path $OutputFile
    }
}

Function Add-SubFolder {
    param (
        [hashtable]$Ini,
        [string]$Extension,
        [string]$OutputFile
    )
    if ($ini[$extension].ContainsKey("subfolder")) {
        Add-Content -Value "subfolder=$($Ini[$Extension]['subfolder'])`n" -Path $outputFile
    }
}

Function Add-Docs {
    param (
        [string]$InputFile,
        [string]$OutputFile
    )
    [xml]$xml = Get-Content -Path $InputFile
    $docs = $xml.SelectNodes("//*[@role='doc']") | ForEach-Object {
        $_.name -replace "/", "\"
    }
    $docs = $docs -join " "
    Add-Content -Value "docs=$docs" -Path $outputFile
}

Function Add-BuildDir {
    param (
        [string]$Arch,
        [string]$Ts,
        [string]$OutputFile
    )
    $builddir = if ($Arch -eq "x64") { "x64\" } else { "" }
    $builddir += "Release"
    if ($Ts -eq "ts") { $builddir += "_TS" }
    Add-Content -Value "builddir=$builddir" -Path $outputFile
}

$outputFile = if ($env:GITHUB_OUTPUT) { $env:GITHUB_OUTPUT } else { "output.txt" }

$versions = Get-Versions -InputFile 'config\vs.json'
if (-not $versions.PSObject.Properties.Name -contains $Version) {
    throw "Unsupported version: $Version"
}

$ini = Get-IniData -Path (Join-Path $PSScriptRoot "..\config\pecl.ini")
if (-not $ini.ContainsKey($Extension)) {
    throw "Unsupported extension: $Extension"
}

Add-VSVersion -Versions $versions -OutputFile $outputFile
Add-Config -Ini $ini -Extension $Extension -OutputFile $outputFile
Add-Libs -Ini $ini -Extension $Extension -OutputFile $outputFile
Add-PECLLibs -Ini $ini -Extension $Extension -OutputFile pecl_libs.csv
Add-Extensions -Ini $ini -Extension $Extension -OutputFile extensions.csv
Add-SubFolder -Ini $ini -Extension $Extension -OutputFile $outputFile
Add-Docs -InputFile package.xml -OutputFile $outputFile
Add-BuildDir -Arch $Arch -Ts $Ts -OutputFile $outputFile
