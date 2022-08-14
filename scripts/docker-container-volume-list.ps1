$volumes = docker volume ls -q

$entries = New-Object Collections.Generic.List[Collections.HashTable]
$volumes | ForEach-Object {
    # Last line of output from docker container ls is the line of interest
    # Split this line with " "
    $result = $(docker container ls -a --filter volume=$_ --format "{{json .}}")
    if($result -ne $null)
    {
        $result = ConvertFrom-Json $result -AsHashtable
        $entries.Add(@{"volume-id" = $_
                ;"container-id" = $result["ID"]
                ;"image-name" = $result["Image"]
                ;"container-name" = $result["Names"]
            })
    }
}

Write-Host "volume-id --- container-id --- image-name --- container-name"
$entries | ForEach-Object {
    Write-Host "$($_['volume-id']) --- $($_['container-id']) --- $($_['image-name']) --- $($_['container-name'])"
}