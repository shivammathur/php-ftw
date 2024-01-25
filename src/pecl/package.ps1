param (
    [string]$Extension,
    [string]$Version,
    [string]$PhpVersion,
    [string]$Ts,
    [string]$Vs,
    [string]$Arch,
    [string]$BuildDir,
    [String[]]$Docs
)

Set-Location $Extension-$Version
New-Item -Path ..\install -ItemType Directory -Force | Out-Null
xcopy ..\..\deps\LICENSE* ..\install\*
xcopy COPYING ..\install\*
xcopy COPYRIGHT ..\install\*
xcopy LICENSE ..\install\*
$Docs | ForEach-Object {
    $directoryPath = [System.IO.Path]::GetDirectoryName($_)
    $targetDir = Join-Path -Path "..\install" -ChildPath $directoryPath
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    Copy-Item -Path $_ -Destination $targetDir -Force
}
xcopy $BuildDir\*.dll ..\install\*
Get-ChildItem -Path "..\install\*.dll" | ForEach-Object {
    $pdbFilePath = Join-Path -Path $BuildDir -ChildPath ($_.BaseName + ".pdb")
    if (Test-Path -Path $pdbFilePath) {
        Copy-Item -Path $pdbFilePath -Destination "..\install\" -Force
    }
}
Set-Location ..\install
if(Test-Path -Path "vc140.pdb") {
    Remove-Item -Path "vc140.pdb" -Force
}
7z a -sdel php_$Extension-$Version-$PhpVersion-$Ts-$Vs-$Arch.zip *
Set-Location ..\$Extension-$Version
xcopy *-php_$Extension-$Version-$PhpVersion-$Ts-$Vs-$Arch.txt ..\install\logs\*
Set-Location ..\install\logs
7z a -sdel php_$Extension-$Version-$PhpVersion-$Ts-$Vs-$Arch.zip *
