param(
    [string]$vs,
    [string]$arch
)

if (Test-Path -Path "pecl_libs.csv") {
    Import-Csv -Path "pecl_libs.csv" | ForEach-Object {
        $libName = $_.Name
        $url = "https://windows.php.net/downloads/pecl/deps/$libName-$vs-$arch.zip"
        $outputZip = "$libName-$vs-$arch.zip"
        Invoke-WebRequest -Uri $url -OutFile $outputZip -UseBasicParsing
        7z x -o"..\deps" $outputZip
    }
}
