param (
    [string]$Extension,
    [string]$Version
)

$fileName = "${Extension}-${Version}.tgz"
Invoke-WebRequest -Uri "https://pecl.php.net/get/$fileName" -OutFile $fileName -UseBasicParsing

7z x $fileName
7z x -y "${Extension}-${Version}.tar"