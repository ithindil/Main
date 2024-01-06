$mkvMergePath = "C:\Users\iTHiNDiL\Desktop\mkvtoolnix\mkvmerge.exe"

function Get-MKVTrackInfo {
    [CmdletBinding()]
    
    Param
    (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)] [string] $File

    )
    
    $tracks = (& $mkvMergePath --ui-language en -J $File | ConvertFrom-Json).tracks

    $Array = @()
    foreach ($track in $tracks) {
        #Check Audio Tracks
        if ($null -ne $track.properties.audio_channels) {

            $Array += [PSCustomObject]@{
                Type            = "Audio"
                Language        = $track.properties.language
                "Language Name" = $track.properties.track_name
            
            }
        }

        #Check Subtitle Tracks
        if ($null -ne $track.properties.text_subtitles) {

            $Array += [PSCustomObject]@{
                Type            = "Subtitle"
                Language        = $track.properties.language
                "Language Name" = $track.properties.track_name
            
            }
        }
    }

    Return $Array
   
}

$FilePath = "\\SERVER\Storage\Torrents\Anime\[PuyaSubs!] Hamatora"
Get-MKVTrackInfo -File $FilePath


$Folder = Get-ChildItem -LiteralPath '\\server\Storage\Torrents\Anime\' -Recurse -File | `
    Where-Object {$_.Name -like '*Hikikomari *'} | Sort-Object

foreach ($FilePath in $Folder) {
    "########################################################################################################"
    $FilePath.Name
    "--------------------------------------------------------------------------------------------------------"
    Get-MKVTrackInfo -File $FilePath.FullName
}


