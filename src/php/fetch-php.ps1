param (
    [Parameter(Mandatory)]
    [string] $version,
    [Parameter(Mandatory)]
    [string] $arch,
    [Parameter(Mandatory)]
    [string] $ts
)

$ErrorActionPreference = "Stop"

$jsonContent = Get-Content -Path config/vs.json -Raw
$versions = ConvertFrom-Json -InputObject $jsonContent
$major_minor = $version.Substring(0, 3)
$vs=$($versions.$major_minor)
if (-not $vs) {
    throw "unsupported PHP version"
}

$what = if ($version -match "[a-z]") {"qa"} else {"releases"}
$baseurl = "https://windows.php.net/downloads/$what"
$tspart = if ($ts -eq "nts") {"nts-Win32"} else {"Win32"}

$fname = "php-$version-$tspart-$vs-$arch.zip"
$url = "$baseurl/$fname"
Invoke-WebRequest $url -OutFile $fname
7z "x" $fname "-ophpbin"

$fname = "php-test-pack-$version.zip"
$url = "$baseurl/$fname"
Invoke-WebRequest $url -OutFile $fname
7z "x" $fname "-otests"
