param(
    [string]$Extension,
    [string]$Config,
    [string]$Prefix
)

Invoke-WebRequest -Uri "https://pecl.php.net/get/$Extension" -OutFile "$Extension.tgz"
7z x "$Extension.tgz"
7z x -y "$Extension.tar"
Set-Location "$Extension-*"
& phpize
.\configure.bat --with-php-build=..\..\deps $Config --with-prefix=$Prefix
& nmake
& nmake install
