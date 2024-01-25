param (
    [string]$Prefix
)

if (Test-Path extensions.csv) {
    Import-Csv -Path extensions.csv | ForEach-Object {
        $extension = $_.Extension
        $config = $_.Config
        & "src\pecl\install-pecl-dep.ps1" -Extension $extension -Config $config -Prefix $Prefix
    }
}