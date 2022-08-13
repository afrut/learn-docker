# TODO: modify this to use quiet mode (-q) to return only id's.
$volumes_ = docker volume ls
$volumes = New-Object Collections.Generic.List[String]
for($cntv = 1; $cntv -lt $volumes_.Length; $cntv++)
{
    # Last element of every line split by space is the volume-id
    $volumes.Add($volumes_[$cntv].Split(" ")[-1])
}

$volumes = $volumes.ToArray()

$entries = New-Object Collections.Generic.List[Collections.HashTable]
$volumes | ForEach-Object {
    # Last line of output from docker container ls is the line of interest
    # Split this line with " "
    $result = $(docker container ls -a --filter volume=$_)

    if($result.GetType() -eq [System.Object[]] -and $result.Length -ge 2)
    {
        $result = $result[-1].Split(" ")
        $ls = New-Object Collections.Generic.List[String]
        for($cnt = 0; $cnt -lt $result.Length; $cnt++)
        {
            if($result[$cnt] -ne ""){
                    $ls.Add($result[$cnt])
            }
        }
                
        $entries.Add(@{"volume-id" = $_
            ;"container-id" = $ls[0]
            ;"image-name" = $ls[1]
            ;"container-name" = $ls[-1]
        })
    }
}

Write-Host "volume-id --- container-id --- image-name --- container-name"
$entries | ForEach-Object {
    Write-Host "$($_['volume-id']) --- $($_['container-id']) --- $($_['image-name']) --- $($_['container-name'])"
}