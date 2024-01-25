param (
    [Parameter(Mandatory)] $version,
    [Parameter(Mandatory)] $arch,
    [Parameter(Mandatory)] $ts
)

$ErrorActionPreference = "Stop"

Set-Location "config\php\vs16\$arch\php-$version"

New-Item "..\obj" -ItemType "directory"
Copy-Item "..\config.$ts.bat"

$task = "src\php\runner\task-$ts.bat"

& "..\..\..\..\..\php-sdk\phpsdk-vs16-$arch.bat" -t $task
if (-not $?) {
    throw "build failed with errorlevel $LastExitCode"
}

$artifacts = if ($ts -eq "ts") {"..\obj\Release_TS\php-*.zip"} else {"..\obj\Release\php-*.zip"}
xcopy $artifacts "..\..\..\..\..\artifacts\*"
