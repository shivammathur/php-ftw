param (
    [string]$Extension,
    [string]$Version,
    [string]$PhpVersion,
    [string]$Ts,
    [string]$Vs,
    [string]$Arch,
    [string]$Config
)

Set-Location "${Extension}-${Version}"
$configureOutput = .\configure.bat --with-php-build="..\..\deps" $Config --with-mp="disable" --enable-debug-pack 2>&1
$configureOutput | Out-File -FilePath "configure-php_${Extension}-${Version}-${PhpVersion}-${Ts}-${Vs}-${Arch}.txt"