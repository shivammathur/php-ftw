param (
    [string]$Extension,
    [string]$Version,
    [string]$PhpVersion,
    [string]$Ts,
    [string]$Vs,
    [string]$Arch
)

Set-Location "${Extension}-${Version}"
$makeOutput = nmake 2>&1
$makeOutput | Out-File -FilePath "make-php_${Extension}-${Version}-${PhpVersion}-${Ts}-${Vs}-${Arch}.txt"