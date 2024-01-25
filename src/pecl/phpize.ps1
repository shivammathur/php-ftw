param (
    [string]$Extension,
    [string]$Version,
    [string]$PhpVersion,
    [string]$Ts,
    [string]$Vs,
    [string]$Arch
)

Set-Location "${Extension}-${Version}"
$phpizeOutput = phpize 2>&1
$phpizeOutput | Out-File -FilePath "phpize-php_${Extension}-${Version}-${PhpVersion}-${Ts}-${Vs}-${Arch}.txt"