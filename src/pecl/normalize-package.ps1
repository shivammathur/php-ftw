param (
    [string]$Extension,
    [string]$Version,
    [string]$Subfolder
)

Set-Location "${Extension}-${Version}"
Copy-Item -Path "${Subfolder}\*" -Destination "." -Recurse -Force
Remove-Item -Path $Subfolder -Recurse -Force
Set-Location ..