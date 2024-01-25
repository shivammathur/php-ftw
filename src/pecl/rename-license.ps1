if (Test-Path pecl_libs.csv) {
    Import-Csv -Path pecl_libs.csv | ForEach-Object {
        $libName = $_.Name.Split('-')[0] # Assuming the name is in the first part before a '-'
        Rename-Item -Path "..\deps\LICENSE" -NewName "..\deps\LICENSE.$libName"
    }
}